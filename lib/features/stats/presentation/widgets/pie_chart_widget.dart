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
    final sections = <PieChartSectionData>[];
    
    if (proteinPercent > 0) {
      sections.add(PieChartSectionData(
        value: proteinPercent,
        title: '${proteinPercent.toStringAsFixed(0)}%',
        color: Colors.green,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
    if (fatsPercent > 0) {
      sections.add(PieChartSectionData(
        value: fatsPercent,
        title: '${fatsPercent.toStringAsFixed(0)}%',
        color: Colors.red,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
    if (carbsPercent > 0) {
      sections.add(PieChartSectionData(
        value: carbsPercent,
        title: '${carbsPercent.toStringAsFixed(0)}%',
        color: Colors.orange,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
    
    // Если все нули — показываем пустой круг
    if (sections.isEmpty) {
      sections.add(PieChartSectionData(
        value: 100,
        title: '0%',
        color: Colors.grey.withOpacity(0.3),
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          color: Colors.white54,
        ),
      ));
    }

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        startDegreeOffset: -90,
      ),
    );
  }
}