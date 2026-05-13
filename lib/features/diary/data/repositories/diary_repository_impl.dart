import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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

  @override
  Future<Either<Failure, void>> addMealItem(Meal meal, String? productId) async {
    debugPrint('🔍 Repository: addMealItem');
    debugPrint('  mealId: ${meal.id}');
    debugPrint('  productId: $productId');
    
    try {
      await dataSource.addMealItem(meal, productId);
      debugPrint('✅ Repository: addMealItem успешно');
      return const Right(null);
    } on ServerException catch (e) {
      debugPrint('❌ Repository: addMealItem ServerException: $e');
      return Left(ServerFailure());
    } catch (e, stack) {
      debugPrint('❌ Repository: addMealItem ошибка: $e');
      debugPrint('📋 Stack: $stack');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateMealItem(Meal meal) async {
    try {
      await dataSource.updateMealItem(meal);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteMealItem(String mealId) async {
    try {
      await dataSource.deleteMealItem(mealId);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}