import '../../domain/entities/meal.dart';
import '../models/meal_model.dart';

abstract class DiaryMockDataSource {
  Future<DailyGoalsModel> getDailyGoals(DateTime date);
  Future<List<MealModel>> getMealsByType(MealType type, DateTime date);
}

class DiaryMockDataSourceImpl implements DiaryMockDataSource {
  @override
  Future<DailyGoalsModel> getDailyGoals(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const DailyGoalsModel(
      proteinTarget: 100, fatsTarget: 65, carbsTarget: 285, caloriesTarget: 2500,
      proteinCurrent: 100, fatsCurrent: 55, carbsCurrent: 60, caloriesCurrent: 2956);
  }

  @override
  Future<List<MealModel>> getMealsByType(MealType type, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    switch (type) {
      case MealType.breakfast:
        return [
          MealModel(id: '1', name: 'Овсянка с ягодами', weight: '250 г', calories: 351, 
            protein: 12, fats: 8, carbs: 55, createdAt: DateTime.now()),
          MealModel(id: '2', name: 'Очень длинное название блюда которое не помещается ...', 
            weight: '100 г', calories: 351, protein: 20, fats: 15, carbs: 30, createdAt: DateTime.now()),
        ];
      case MealType.lunch:
        return [
          MealModel(id: '3', name: 'Гречка с курицей', weight: '350 г', calories: 520, 
            protein: 35, fats: 12, carbs: 65, createdAt: DateTime.now()),
        ];
      case MealType.dinner:
        return [MealModel(id: '5', name: 'Рыба на пару', weight: '200 г', calories: 280, 
            protein: 40, fats: 10, carbs: 5, createdAt: DateTime.now())];
      case MealType.snack: return [];
    }
  }
}