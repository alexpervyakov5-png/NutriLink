import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/meal.dart';

class GoalsSection extends StatelessWidget {
  final DailyGoals goals;
  const GoalsSection({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // 🎯 Заголовок "Цель" по центру
          const Text(
            'Цель',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // 📊 Все 4 показателя в одной строке (полные названия)
          _buildGoalsTable(),
        ],
      ),
    );
  }

  // ✅ Таблица с 4 показателями в одну строку
  Widget _buildGoalsTable() {
    return Row(
      children: [
        Expanded(child: _buildGoalCell('Белки', goals.proteinCurrent, goals.proteinTarget, AppColors.progressProtein)),
        const SizedBox(width: 6),
        Expanded(child: _buildGoalCell('Жиры', goals.fatsCurrent, goals.fatsTarget, AppColors.progressFats)),
        const SizedBox(width: 6),
        Expanded(child: _buildGoalCell('Углеводы', goals.carbsCurrent, goals.carbsTarget, AppColors.progressCarbs)),
        const SizedBox(width: 6),
        Expanded(child: _buildGoalCell('Калории', goals.caloriesCurrent, goals.caloriesTarget, AppColors.progressCalories)),
      ],
    );
  }

  // ✅ Ячейка таблицы (один показатель)
  Widget _buildGoalCell(String label, int current, int total, Color defaultColor) {
    final color = _getGoalColor(current, total);
    final progress = total > 0 ? current.toDouble() / total.toDouble() : 0.0;

    return Column(
      children: [
        // Label (Белки/Жиры/Углеводы/Калории)
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        // Прогресс бар
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.backgroundSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        // Значения (100/100)
        Text(
          '$current/$total',
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 🎨 Логика выбора цвета
  Color _getGoalColor(int current, int target) {
    if (target == 0) {
      return current == 0 ? Colors.green : Colors.orange;
    }

    final ratio = current.toDouble() / target.toDouble();

    // 🟢 Идеально: 95-100%
    if (ratio >= 0.95 && ratio <= 1.0) {
      return Colors.green;
    }

    // 🟡 Близко: 80-95% или 100-110%
    if ((ratio >= 0.80 && ratio < 0.95) || (ratio > 1.0 && ratio <= 1.10)) {
      return Colors.amber;
    }

    // 🟠 Недобор: < 80%
    if (ratio < 0.80) {
      return Colors.orange;
    }

    // 🔴 Перебор: > 110%
    if (ratio > 1.10) {
      return Colors.red;
    }

    return Colors.grey;
  }
}