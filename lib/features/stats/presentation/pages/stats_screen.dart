import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/stats.dart';
import '../bloc/stats_bloc.dart';
import '../bloc/stats_event.dart';
import '../bloc/stats_state.dart';
import '../widgets/stats_row.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/chart_legend.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          // ✅ Отладка состояния
          debugPrint('📊 StatsScreen build: isLoading=${state.isLoading}, '
              'hasStats=${state.stats != null}, error=${state.error}');

          return Column(
            children: [
              _buildHeader(context, state),
              
              if (state.isLoading && state.stats == null)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (state.error != null)
                Expanded(child: _buildErrorState(context, state.error!))
              else if (state.stats != null)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      debugPrint('🔄 Pull-to-refresh triggered');
                      context.read<StatsBloc>().add(RefreshStats());
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStreakCard(state.stats!.streakDays),
                          const SizedBox(height: 16),
                          _buildNutritionCard(state.stats!.nutrition),
                          const SizedBox(height: 16),
                          _buildPieChartCard(state.stats!.nutrition),
                          const SizedBox(height: 16),
                          _buildWeightChartCard(state.stats!.weightTrend),
                        ],
                      ),
                    ),
                  ),
                )
              else
                // ✅ Fallback если ничего не подходит
                const Expanded(
                  child: Center(
                    child: Text('Нет данных', style: TextStyle(color: AppColors.textHint)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StatsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(color: AppColors.background, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Период',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(state.startDate)} — ${_formatDate(state.endDate)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          if (state.isRefreshing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
              onPressed: () {
                debugPrint('🔄 Refresh button pressed');
                context.read<StatsBloc>().add(RefreshStats());
              },
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    debugPrint('❌ Showing error state: $error');
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 48),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              debugPrint('🔄 Retry button pressed');
              final now = DateTime.now();
              final start = DateTime(now.year, now.month - 1, now.day);
              context.read<StatsBloc>().add(LoadStats(startDate: start, endDate: now));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int streakDays) {
    debugPrint('🔥 Streak card: $streakDays days');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.2), 
            AppColors.backgroundSecondary
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_fire_department, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Текущая серия',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  streakDays > 0 
                      ? '$streakDays ${_pluralizeDays(streakDays)} подряд'
                      : 'Начните серию сегодня!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: streakDays > 0 ? 18 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (streakDays > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('🔥', style: TextStyle(fontSize: 16)),
            ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(NutritionStats stats) {
    debugPrint('🥗 Nutrition card: ${stats.calories} kcal, P:${stats.protein} F:${stats.fats} C:${stats.carbs}');
    
    final hasData = stats.calories > 0 || stats.protein > 0 || stats.fats > 0 || stats.carbs > 0;
    
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
                'За период',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Нет данных о питании за этот период',
                style: TextStyle(color: AppColors.textHint, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            )
          else ...[
            StatsRow(
              label: 'Белки',
              value: '${stats.protein} г',
              percent: '${stats.proteinPercent.toStringAsFixed(1)}%',
              color: Colors.green,
              icon: Icons.local_fire_department,
            ),
            StatsRow(
              label: 'Жиры',
              value: '${stats.fats} г',
              percent: '${stats.fatsPercent.toStringAsFixed(1)}%',
              color: Colors.red,
              icon: Icons.water_drop,
            ),
            StatsRow(
              label: 'Углеводы',
              value: '${stats.carbs} г',
              percent: '${stats.carbsPercent.toStringAsFixed(1)}%',
              color: Colors.orange,
              icon: Icons.grain,
            ),
            const Divider(color: AppColors.background, height: 24),
            StatsRow(
              label: 'Калории',
              value: '${stats.calories}',
              percent: '100%',
              color: AppColors.accentLight,
              icon: Icons.bolt,
              isTotal: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPieChartCard(NutritionStats stats) {
    debugPrint('🥧 Pie chart: P=${stats.proteinPercent}%, F=${stats.fatsPercent}%, C=${stats.carbsPercent}%');
    
    final hasData = stats.proteinPercent > 0 || stats.fatsPercent > 0 || stats.carbsPercent > 0;
    
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
          
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.pie_chart_outline, color: AppColors.textHint, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Нет данных для диаграммы',
                    style: TextStyle(color: AppColors.textHint, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 200,
              child: PieChartWidget(
                proteinPercent: stats.proteinPercent,
                fatsPercent: stats.fatsPercent,
                carbsPercent: stats.carbsPercent,
              ),
            ),
          
          const SizedBox(height: 16),
          const ChartLegend(),
        ],
      ),
    );
  }

  Widget _buildWeightChartCard(List<WeightTrendPoint> trend) {
    debugPrint('⚖️ Weight chart: ${trend.length} points');
    
    // ✅ Отладка: выводим все точки
    if (trend.isNotEmpty) {
      for (var i = 0; i < trend.length; i++) {
        debugPrint('  Point $i: ${trend[i].date} -> ${trend[i].weightKg} kg');
      }
    }
    
    return Container(
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
              const Icon(Icons.monitor_weight, color: AppColors.accentLight, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Динамика веса',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (trend.isNotEmpty)
                Text(
                  '${trend.length} ${_pluralizeMeasurements(trend.length)}',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (trend.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.monitor_weight_outlined, color: AppColors.textHint, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Нет данных о весе',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добавьте замеры во вкладке "Замеры"\nс указанием веса',
                    style: TextStyle(color: AppColors.textHint, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else if (trend.length == 1)
            // ✅ Показываем одну точку как карточку
            _buildSingleWeightPoint(trend.first)
          else
            SizedBox(
              height: 200,
              child: _buildWeightLineChart(trend),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleWeightPoint(WeightTrendPoint point) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.monitor_weight, color: AppColors.accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${point.weightKg.toStringAsFixed(1)} кг',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDateFull(point.date),
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightLineChart(List<WeightTrendPoint> trend) {
    debugPrint('📈 Building line chart with ${trend.length} points');
    
    if (trend.length < 2) {
      return Center(
        child: Text(
          'Нужно минимум 2 замера для графика',
          style: TextStyle(color: AppColors.textHint, fontSize: 12),
        ),
      );
    }

    final weights = trend.map((p) => p.weightKg).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    
    // ✅ Добавляем отступы для красоты графика
    final padding = (maxWeight - minWeight) * 0.1;
    final minY = minWeight - padding;
    final maxY = maxWeight + padding;

    debugPrint('  Chart Y range: $minY - $maxY');

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateGridInterval(minY, maxY),
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.background,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _calculateDateInterval(trend.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= trend.length) return const SizedBox();
                
                // ✅ Показываем даты с шагом
                final date = trend[index].date;
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    '${date.day}.${date.month}',
                    style: TextStyle(color: AppColors.textHint, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: _calculateGridInterval(minY, maxY),
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(color: AppColors.textHint, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.background, width: 1),
        ),
        minX: 0,
        maxX: (trend.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              trend.length,
              (i) => FlSpot(i.toDouble(), trend[i].weightKg),
            ),
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.accentLight,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: index == trend.length - 1 ? 5 : 3, // ✅ Последняя точка больше
                color: index == trend.length - 1 
                    ? AppColors.accent 
                    : AppColors.accentLight,
                strokeWidth: 2,
                strokeColor: AppColors.backgroundSecondary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accentLight.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppColors.backgroundSecondary,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final point = trend[spot.x.toInt()];
                return LineTooltipItem(
                  '${point.weightKg.toStringAsFixed(1)} кг\n${_formatDateFull(point.date)}',
                  TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  // ✅ Вспомогательные методы
  
  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yy').format(date);
  }

  String _formatDateFull(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'ru_RU').format(date);
  }

  String _pluralizeDays(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'день';
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) return 'дня';
    return 'дней';
  }

  String _pluralizeMeasurements(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'замер';
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) return 'замера';
    return 'замеров';
  }

  double _calculateGridInterval(double min, double max) {
    final range = max - min;
    if (range <= 2) return 0.5;
    if (range <= 5) return 1;
    if (range <= 10) return 2;
    if (range <= 20) return 5;
    return 10;
  }

  double _calculateDateInterval(int totalPoints) {
    if (totalPoints <= 5) return 1;
    if (totalPoints <= 10) return 2;
    if (totalPoints <= 20) return 3;
    return 5;
  }
}