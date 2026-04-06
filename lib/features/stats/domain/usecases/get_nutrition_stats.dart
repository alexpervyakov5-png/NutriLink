import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stats.dart';
import '../repositories/stats_repository.dart';
import '../../../measurements/domain/entities/measurement.dart';

class GetNutritionStatsParams extends Equatable {
  final MeasurementPeriod period;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetNutritionStatsParams({
    required this.period,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [period, startDate, endDate];
}

class GetNutritionStats implements UseCase<Either<Failure, NutritionStats>, GetNutritionStatsParams> {
  final StatsRepository repository;
  GetNutritionStats(this.repository);

  @override
  Future<Either<Failure, NutritionStats>> call(GetNutritionStatsParams params) async {
    return await repository.getNutritionStats(params.period, params.startDate, params.endDate);
  }
}