import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stats.dart';
import '../repositories/stats_repository.dart';

class GetStatsDataParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const GetStatsDataParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

class GetStatsData implements UseCase<Either<Failure, StatsData>, GetStatsDataParams> {
  final StatsRepository repository;

  GetStatsData(this.repository);

  @override
  Future<Either<Failure, StatsData>> call(GetStatsDataParams params) async {
    return await repository.getStatsData(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}