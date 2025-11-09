import 'package:flutter/material.dart';
'attitude': 3,
'cleaning': 3,
'hygiene': 3,
'communication': 3,
'speed': 3,
'accuracy': 3,
'stock': 3,
'cashier': 3,
'prep': 3,
'safety': 3,
};
final Set<String> _areas = {'棚','床','トイレ'};
String _ai = '';
bool _saving = false;


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('セルフチェック')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._scores.keys.map((k) => _scoreTile(k)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final a in ['棚','床','トイレ','外周','フィルター','ゴミ','ガラス','什器','犬走','バックヤード'])
            FilterChip(
              label: Text(a),
              selected: _areas.contains(a),
              onSelected: (v){ setState((){ v ? _areas.add(a) : _areas.remove(a); }); },
            ),
        ]),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _saving ? null : _generateAndSave,
          icon: const Icon(Icons.save_outlined),
          label: Text(_saving ? '保存中…' : 'AIコメント生成して保存'),
        ),
        if (_ai.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(_ai))),
        ],
      ],
    ),
  );
}


Widget _scoreTile(String key) {
  return ListTile(
    title: Text(key),
    subtitle: Slider(
      min: 1, max: 5, divisions: 4,
      value: (_scores[key] ?? 3).toDouble(),
      label: '${_scores[key]}',
      onChanged: (v) => setState(() => _scores[key] = v.toInt()),
    ),
    trailing: Text('${_scores[key]}'),
  );
}


Future<void> _generateAndSave() async {
  setState(() => _saving = true);
  final comment = await AiFeedbackService.instance.buildComment(
    scores: _scores, areas: _areas.toList(),
  );
  final now = DateTime.now().toUtc();
  final c = Checkin(
    id: '${now.toIso8601String()}-demo',
    uid: 'demo', storeId: 'demo-store', date: now,
    scores: Map.of(_scores), cleaningAreas: _areas.toList(), aiComment: comment,
  );
  await FirestoreService.instance.saveCheckin(c);
  setState(() { _ai = comment; _saving = false; });
}
}