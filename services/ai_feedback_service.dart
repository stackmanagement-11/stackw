import 'dart:convert';
import 'package:http/http.dart' as http;


class AiFeedbackService {
  AiFeedbackService._();
  static final instance = AiFeedbackService._();


  Future<String> buildComment({required Map<String, int> scores, required List<String> areas}) async {
    final apiKey = const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    if (apiKey.isEmpty) return '（デモ）良かった点：清掃の徹底。改善：報連相をもう一歩。';


    final prompt = '''あなたはコンビニ店舗の現場コーチです。以下のスコア（1-5）と清掃領域から、
- 褒める点（1〜2点）
- 具体的な改善提案（1〜2点）
を **120字以内の日本語** でまとめてください。
Scores: ${jsonEncode(scores)}
Cleaning: ${areas.join(', ')}
''';


    final resp = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': '短く、現場で行動に移せる日本語で。'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.3,
        'max_tokens': 180,
      }),
    );


    if (resp.statusCode == 200) {
      final m = jsonDecode(resp.body) as Map<String, dynamic>;
      return m['choices'][0]['message']['content'] as String;
    }
    return 'AIコメント生成に失敗しました（${resp.statusCode}）';
  }
}