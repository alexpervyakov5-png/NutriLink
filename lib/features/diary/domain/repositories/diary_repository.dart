import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/meal.dart';

abstract class DiaryRepository {
  Future<Either<Failure, DailyGoals>> getDailyGoals(DateTime date);
  Future<Either<Failure, List<Meal>>> getMealsByType(MealType type, DateTime date);
}