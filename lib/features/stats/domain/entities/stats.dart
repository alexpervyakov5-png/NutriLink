class NutritionStats {
  final int protein;
  final int fats;
  final int carbs;
  final int calories;
  final double proteinPercent;
  final double fatsPercent;
  final double carbsPercent;

  const NutritionStats({
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.calories,
    required this.proteinPercent,
    required this.fatsPercent,
    required this.carbsPercent,
  });

  factory NutritionStats.fromMacros({
    required int protein,
    required int fats,
    required int carbs,
    required int calories,
  }) {
    final total = protein + fats + carbs;
    return NutritionStats(
      protein: protein,
      fats: fats,
      carbs: carbs,
      calories: calories,
      proteinPercent: total > 0 ? (protein / total * 100) : 0,
      fatsPercent: total > 0 ? (fats / total * 100) : 0,
      carbsPercent: total > 0 ? (carbs / total * 100) : 0,
    );
  }
}