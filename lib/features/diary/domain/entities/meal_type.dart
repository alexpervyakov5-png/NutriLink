enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

// ✅ Helper метод для отображения
extension MealTypeExtension on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast: return 'Завтрак';
      case MealType.lunch: return 'Обед';
      case MealType.dinner: return 'Ужин';
      case MealType.snack: return 'Перекус';
    }
  }
}