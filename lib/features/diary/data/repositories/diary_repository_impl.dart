import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/daily_goals.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_supabase_datasource.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiarySupabaseDataSource dataSource;

  DiaryRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, DailyGoals>> getDailyGoals(DateTime date) async {
    try {
      final result = await dataSource.getDailyGoals(date);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByType(MealType type, DateTime date) async {
    try {
      final result = await dataSource.getMealsByType(type, date);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  // ✅ Реализация сохранения
  @override
  Future<Either<Failure, void>> addMeal(Meal meal) async {
    try {
      await dataSource.addMeal(meal);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateMeal(Meal meal) async {
    try {
      await dataSource.updateMeal(meal);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteMeal(String mealId) async {
    try {
      await dataSource.deleteMeal(mealId);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}