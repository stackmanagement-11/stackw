import { onCall } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import fetch from "node-fetch";

initializeApp();
const db = getFirestore();steps:
                            - name: 'gcr.io/cloud-builders/npm'
                              args: ['install']

                            - name: 'gcr.io/cloud-builders/npm'
                              args: ['run', 'build']

                          timeout: '1200s'
steps:
  - name: 'gcr.io/cloud-builders/npm'
    args: ['install']

  - name: 'gcr.io/cloud-builders/npm'
    args: ['run', 'build']

timeout: '1200s'


// ★ ここがポイント：シークレットを宣言
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const weeklySummary = onCall({ secrets: [OPENAI_API_KEY] }, async (req) => {
  const { storeId, weekStartIso } = req.data || {};
  if (!storeId || !weekStartIso) return { ok:false, error:"storeId and weekStartIso are required" };

  const start = new Date(weekStartIso);
  const end = new Date(start); end.setDate(start.getDate() + 7);

  const snap = await db.collection("stores").doc(storeId)
    .collection("checkins")
    .where("date", ">=", start.toISOString())
    .where("date", "<",  end.toISOString())
    .get();

  const items = snap.docs.map(d => d.data());
  const avg = items.length
    ? items.map(x => {
        const v = Object.values(x.scores || {}).map(Number);
        return v.length ? v.reduce((a,b)=>a+b,0) / v.length : 0;
      }).reduce((a,b)=>a+b,0) / items.length
    : 0;

  const prompt = "以下の1週間のセルフチェックから、店舗の傾向と改善提案を200字以内で要約:\n" +
                 JSON.stringify(items).slice(0,4000);

  let ai = "";
  try {
    const r = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${OPENAI_API_KEY.value()}`, // ← ここも変更
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [{ role:"user", content: prompt }],
        temperature: 0.2
      })
    });
    const j = await r.json();
    ai = j?.choices?.[0]?.message?.content ?? "";
  } catch(e) { ai = "(AI生成エラー) " + String(e); }

  await db.collection("stores").doc(storeId).collection("metrics")
    .doc(weekStartIso.substring(0,10))
    .set({ storeId, avgScore: avg, aiSummaryStore: ai, createdAt: new Date().toISOString() }, { merge:true });

  return { ok:true, avg, ai };
});
