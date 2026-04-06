import '../../domain/entities/stats.dart';

class StatsModel extends NutritionStats {
  const StatsModel({
    required super.protein,
    required super.fats,
    required super.carbs,
    required super.calories,
    required super.proteinPercent,
    required super.fatsPercent,
    required super.carbsPercent,
  });

  factory StatsModel.fromNutritionStats(NutritionStats stats) {
    return StatsModel(
      protein: stats.protein,
      fats: stats.fats,
      carbs: stats.carbs,
      calories: stats.calories,
      proteinPercent: stats.proteinPercent,
      fatsPercent: stats.fatsPercent,
      carbsPercent: stats.carbsPercent,
    );
  }
}