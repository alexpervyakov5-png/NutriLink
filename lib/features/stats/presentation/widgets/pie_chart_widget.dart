import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final double proteinPercent;
  final double fatsPercent;
  final double carbsPercent;

  const PieChartWidget({
    super.key,
    required this.proteinPercent,
    required this.fatsPercent,
    required this.carbsPercent,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sections: _generatingSections(),
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatingSections() {
    return [
      PieChartSectionData(
        value: proteinPercent,
        title: '${proteinPercent.toStringAsFixed(1)}%',
        color: Colors.green,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: fatsPercent,
        title: '${fatsPercent.toStringAsFixed(1)}%',
        color: Colors.red,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: carbsPercent,
        title: '${carbsPercent.toStringAsFixed(1)}%',
        color: Colors.orange,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }
}