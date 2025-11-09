import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/checkin.dart';


class ScoreChart extends StatelessWidget {
  final List<Checkin> checkins;
  const ScoreChart({super.key, required this.checkins});


  @override
  Widget build(BuildContext context) {
    final pts = checkins.asMap().entries.map((e) {
      final i = e.key;
      final c = e.value;
      final v = c.scores.values.fold<int>(0, (a,b)=>a+b)/c.scores.length;
      return FlSpot(i.toDouble(), v.toDouble());
    }).toList();


    return LineChart(LineChartData(
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(spots: pts, isCurved: true, dotData: const FlDotData(show: true)),
      ],
      minY: 1, maxY: 5,
    ));
  }
}