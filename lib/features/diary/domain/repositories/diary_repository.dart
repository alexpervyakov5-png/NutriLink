import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/daily_goals.dart';

abstract class DiaryRepository {
  Future<Either<Failure, DailyGoals>> getDailyGoals(DateTime date);
  Future<Either<Failure, List<Meal>>> getMealsByType(MealType type, DateTime date);
  
  // ✅ Обновлено: добавлен параметр productId
  Future<Either<Failure, void>> addMealItem(Meal meal, String? productId);
  Future<Either<Failure, void>> updateMealItem(Meal meal);
  Future<Either<Failure, void>> deleteMealItem(String mealId);
}