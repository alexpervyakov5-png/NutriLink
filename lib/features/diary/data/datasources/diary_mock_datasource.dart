import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/daily_goals.dart';

abstract class DiaryMockDataSource {
  Future<DailyGoals> getDailyGoals(DateTime date);
  Future<List<Meal>> getMealsByType(MealType type, DateTime date);
}

class DiaryMockDataSourceImpl implements DiaryMockDataSource {
  @override
  Future<DailyGoals> getDailyGoals(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // ✅ Используем DailyGoals (не DailyGoalsModel)
    return const DailyGoals(
      proteinTarget: 100,
      fatsTarget: 65,
      carbsTarget: 285,
      caloriesTarget: 2500,
      proteinCurrent: 100,
      fatsCurrent: 55,
      carbsCurrent: 60,
      caloriesCurrent: 2956,
    );
  }

  @override
  Future<List<Meal>> getMealsByType(MealType type, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // ✅ Возвращаем List<Meal> с обязательным mealType
    switch (type) {
      case MealType.breakfast:
        return [
          Meal(
            id: '1',
            name: 'Овсянка с ягодами',
            weight: '250г',  // ✅ Формат "250г" без пробела
            calories: 351,
            protein: 12,
            fats: 8,
            carbs: 55,
            mealType: MealType.breakfast,  // ✅ Обязательный параметр
            createdAt: DateTime(2026, 1, 31),  // ✅ Const-compatible дата
          ),
          Meal(
            id: '2',
            name: 'Очень длинное название блюда которое не помещается ...',
            weight: '100г',
            calories: 351,
            protein: 20,
            fats: 15,
            carbs: 30,
            mealType: MealType.breakfast,
            createdAt: DateTime(2026, 1, 31),
          ),
        ];
        
      case MealType.lunch:
        return [
          Meal(
            id: '3',
            name: 'Гречка с курицей',
            weight: '350г',
            calories: 520,
            protein: 35,
            fats: 12,
            carbs: 65,
            mealType: MealType.lunch,  // ✅ mealType соответствует типу
            createdAt: DateTime(2026, 1, 31),
          ),
        ];
        
      case MealType.dinner:
        return [
          Meal(
            id: '5',
            name: 'Рыба на пару',
            weight: '200г',
            calories: 280,
            protein: 40,
            fats: 10,
            carbs: 5,
            mealType: MealType.dinner,
            createdAt: DateTime(2026, 1, 31),
          ),
        ];
        
      case MealType.snack:
        return [];
    }
  }
}