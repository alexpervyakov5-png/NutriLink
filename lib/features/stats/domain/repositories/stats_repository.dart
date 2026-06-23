import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stats.dart';

abstract class StatsRepository {
  Future<Either<Failure, StatsData>> getStatsData({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  Future<Either<Failure, List<WeightTrendPoint>>> getWeightTrend({
    required DateTime startDate,
    required DateTime endDate,
  });
}