import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/measurement.dart';
import '../repositories/measurements_repository.dart';

class GetMeasurementsParams extends Equatable {
  final MeasurementPeriod period;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetMeasurementsParams({
    required this.period,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [period, startDate, endDate];
}

class GetMeasurements implements UseCase<Either<Failure, List<Measurement>>, GetMeasurementsParams> {
  final MeasurementsRepository repository;
  GetMeasurements(this.repository);

  @override
  Future<Either<Failure, List<Measurement>>> call(GetMeasurementsParams params) async {
    return await repository.getMeasurements(params.period, params.startDate, params.endDate);
  }
}