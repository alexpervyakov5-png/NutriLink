import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/stats.dart';
import '../bloc/stats_bloc.dart';
import '../bloc/stats_event.dart';
import '../bloc/stats_state.dart';
import '../widgets/stats_row.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/chart_legend.dart';
import 'graphs_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const _imageProtein = '${AppStrings.assetImages}protein.png';
  static const _imageFats = '${AppStrings.assetImages}fats.png';
  static const _imageCarbs = '${AppStrings.assetImages}carbs.png';
  static const _imageCalories = '${AppStrings.assetImages}calories.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderRow(context),
                const SizedBox(height: 24),
                if (state.stats != null) _buildStatsCard(state.stats!),
                const SizedBox(height: 24),
                if (state.stats != null) _buildPieChartCard(state.stats!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      children: [
        // 📈 Кнопка "Графики"
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GraphsScreen()),
              );
            },
            icon: const Icon(Icons.show_chart, size: 18),
            label: const Text('Графики', style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(NutritionStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Питательные вещества',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Процент',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StatsRow(
            label: 'Белки',
            value: '${stats.protein} gr',
            percent: '${stats.proteinPercent.toStringAsFixed(1)}%',
            color: Colors.green,
            imagePath: _imageProtein,
          ),
          StatsRow(
            label: 'Жиры',
            value: '${stats.fats} gr',
            percent: '${stats.fatsPercent.toStringAsFixed(1)}%',
            color: Colors.red,
            imagePath: _imageFats,
          ),
          StatsRow(
            label: 'Углеводы',
            value: '${stats.carbs} gr',
            percent: '${stats.carbsPercent.toStringAsFixed(1)}%',
            color: Colors.orange,
            imagePath: _imageCarbs,
          ),
          const Divider(color: AppColors.background, height: 24),
          StatsRow(
            label: 'Калории',
            value: '${stats.calories}',
            percent: '100%',
            color: AppColors.accentLight,
            imagePath: _imageCalories,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(NutritionStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Диаграмма БЖУ',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          PieChartWidget(
            proteinPercent: stats.proteinPercent,
            fatsPercent: stats.fatsPercent,
            carbsPercent: stats.carbsPercent,
          ),
          const SizedBox(height: 16),
          const ChartLegend(),
        ],
      ),
    );
  }
}