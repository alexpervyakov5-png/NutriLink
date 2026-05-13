import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stats.dart';
import '../repositories/stats_repository.dart';

class GetNutritionStatsParams {
  final DateTime? startDate;
  final DateTime? endDate;

  GetNutritionStatsParams({
    this.startDate,
    this.endDate,
  });
}

class GetNutritionStats implements UseCase<Either<Failure, NutritionStats>, GetNutritionStatsParams> {
  final StatsRepository repository;

  GetNutritionStats(this.repository);

  @override
  Future<Either<Failure, NutritionStats>> call(GetNutritionStatsParams params) async {
    return await repository.getNutritionStats(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}