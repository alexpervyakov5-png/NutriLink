import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

// Типы графиков
enum GraphType {
  weight('Вес', Icons.monitor_weight),
  chest('Обхват груди', Icons.square),
  waist('Обхват талии', Icons.line_axis),
  hips('Обхват бедер', Icons.show_chart);

  final String label;
  final IconData icon;
  const GraphType(this.label, this.icon);
}

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  GraphType _selectedGraph = GraphType.weight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Графики изменений',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 📊 Выбор типа графика
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildGraphSelector(),
          ),
          // 📈 График
          Expanded(
            child: _buildGraphCard(),
          ),
        ],
      ),
    );
  }

  // 🔘 Селектор типов графиков
  Widget _buildGraphSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: GraphType.values.map((type) {
          final isSelected = _selectedGraph == type;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedGraph = type),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      type.icon,
                      color: isSelected ? Colors.black : AppColors.textHint,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.label,
                      style: TextStyle(
                        color: isSelected ? Colors.black : AppColors.textHint,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 📈 Карточка с графиком
  Widget _buildGraphCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_selectedGraph.icon, color: AppColors.accentLight, size: 20),
              const SizedBox(width: 8),
              Text(
                'График: ${_selectedGraph.label}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 📊 Линейный график
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.2,
              child: _buildLineChart(),
            ),
          ),
          const SizedBox(height: 8),
          // Ось X
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('01.01', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
              Text('15.01', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
              Text('01.02', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
              Text('15.02', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
              Text('01.03', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Дата',
            style: TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 📊 Линейный график (mock данные)
  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.background,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.background, width: 1),
        ),
        minX: 0,
        maxX: 10,
        minY: 48,
        maxY: 65,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 50),
              FlSpot(2, 63.4),
              FlSpot(4, 61.4),
              FlSpot(6, 63.8),
              FlSpot(7, 62.1),
              FlSpot(8, 60.0),
              FlSpot(9, 63.1),
              FlSpot(10, 58.5),
            ],
            isCurved: false,
            color: AppColors.accentLight,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: index == 9 ? Colors.red : AppColors.accentLight,
                  strokeWidth: 2,
                  strokeColor: AppColors.backgroundSecondary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accentLight.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}