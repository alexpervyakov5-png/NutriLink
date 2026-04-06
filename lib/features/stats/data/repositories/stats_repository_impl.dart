import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/stats.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_mock_datasource.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsMockDataSource mockDataSource;

  StatsRepositoryImpl({required this.mockDataSource});

  @override
  Future<Either<Failure, NutritionStats>> getNutritionStats(
    dynamic period,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final stats = await mockDataSource.getNutritionStats(startDate, endDate);
      return Right(stats);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}