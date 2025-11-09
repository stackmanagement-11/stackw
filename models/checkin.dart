class Checkin {
  final String id; // docId（date+uid ハッシュ推奨）
  final String uid; // Firebase Auth UID
  final String storeId; // 所属店舗
  final DateTime date; // 日次キー（UTC始点）
  final Map<String, int> scores; // 例: {"attitude":4, "cleaning":5, ...}
  final List<String> cleaningAreas; // 例: ["棚","床","トイレ"]
  final String? aiComment; // AI コメント（褒め＋改善）


  Checkin({
    required this.id,
    required this.uid,
    required this.storeId,
    required this.date,
    required this.scores,
    required this.cleaningAreas,
    this.aiComment,
  });


  Map<String, dynamic> toMap() => {
    'uid': uid,
    'storeId': storeId,
    'date': date.toUtc().toIso8601String(),
    'scores': scores,
    'cleaningAreas': cleaningAreas,
    'aiComment': aiComment,
  };


  factory Checkin.fromMap(String id, Map<String, dynamic> m) => Checkin(
    id: id,
    uid: m['uid'] as String,
    storeId: m['storeId'] as String,
    date: DateTime.parse(m['date'] as String).toUtc(),
    scores: Map<String, int>.from(m['scores'] as Map),
    cleaningAreas: List<String>.from(m['cleaningAreas'] as List),
    aiComment: m['aiComment'] as String?,
  );
}