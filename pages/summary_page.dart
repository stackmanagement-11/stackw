import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/score_chart.dart';
import '../models/checkin.dart';


class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});
  @override
  State<SummaryPage> createState() => _SummaryPageState();
}


class _SummaryPageState extends State<SummaryPage> {
  List<Checkin> _week = [];
  double _avg = 0;


  @override
  void initState() {
    super.initState();
    _load();
  }


  Future<void> _load() async {
    final monday = _mondayUtc(DateTime.now().toUtc());
    final data = await FirestoreService.instance.fetchWeek('demo-store', monday);
    final values = data.map((c) => c.scores.values.fold<int>(0, (a,b)=>a+b) / c.scores.length).toList();
    setState((){
      _week = data;
      _avg = values.isEmpty ? 0 : values.reduce((a,b)=>a+b) / values.length;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('週報')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('平均スコア: ${_avg.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          Expanded(child: ScoreChart(checkins: _week)),
          const SizedBox(height: 12),
          const Text('※ 本番は Functions 経由で AI 総評を生成し、stores/{storeId}/metrics に保存'),
        ]),
      ),
    );
  }


  DateTime _mondayUtc(DateTime d) => d.subtract(Duration(days: (d.weekday - DateTime.monday) % 7)).copyWith(hour:0,minute:0,second:0,microsecond:0);
}