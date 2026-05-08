import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/stats.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_mock_datasource.dart';
import '../../../measurements/domain/entities/measurement.dart'; // ✅ MeasurementPeriod отсюда

class StatsRepositoryImpl implements StatsRepository {
  final StatsMockDataSource mockDataSource;

  StatsRepositoryImpl({required this.mockDataSource});

  @override
  Future<Either<Failure, NutritionStats>> getNutritionStats(
    MeasurementPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final result = await mockDataSource.getNutritionStats(startDate, endDate);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}