import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/stats.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_supabase_datasource.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsSupabaseDataSource dataSource;

  StatsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, StatsData>> getStatsData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final nutrition = await dataSource.getNutritionStats(
        startDate: startDate,
        endDate: endDate,
      );
      
      final weightTrend = await dataSource.getWeightTrend(
        startDate: startDate,
        endDate: endDate,
      );
      
      final streakDays = await dataSource.getStreakDays();
      
      final stats = StatsData(
        nutrition: nutrition,
        weightTrend: weightTrend,
        streakDays: streakDays,
      );
      
      return Right(stats);
    } on ServerException catch (e) {
      debugPrint('❌ Repository: ServerException: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e, stack) {
      debugPrint('❌ Repository: Ошибка: $e');
      debugPrint('📋 Stack: $stack');
      return Left(ServerFailure(message: 'Не удалось загрузить статистику'));
    }
  }

  @override
  Future<Either<Failure, List<WeightTrendPoint>>> getWeightTrend({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await dataSource.getWeightTrend(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Не удалось загрузить график веса'));
    }
  }
}