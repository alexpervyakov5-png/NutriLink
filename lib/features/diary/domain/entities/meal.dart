enum MealType { breakfast, lunch, dinner, snack }

class Meal {
  final String id;
  final String name;
  final String weight;
  final int calories;
  final int protein;
  final int fats;
  final int carbs;
  final DateTime createdAt;

  Meal({
    required this.id,
    required this.name,
    required this.weight,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.createdAt,
  });
}

class DailyGoals {
  final int proteinTarget, fatsTarget, carbsTarget, caloriesTarget;
  final int proteinCurrent, fatsCurrent, carbsCurrent, caloriesCurrent;

  const DailyGoals({
    required this.proteinTarget,
    required this.fatsTarget,
    required this.carbsTarget,
    required this.caloriesTarget,
    required this.proteinCurrent,
    required this.fatsCurrent,
    required this.carbsCurrent,
    required this.caloriesCurrent,
  });
}