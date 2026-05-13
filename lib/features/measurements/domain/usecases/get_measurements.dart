import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/repositories/measurements_repository.dart';

class GetMeasurements {
  final MeasurementsRepository repository;

  GetMeasurements(this.repository);

  Future<Either<Failure, List<Measurement>>> call(GetMeasurementsParams params) async {
    return await repository.getMeasurements(
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetMeasurementsParams {
  final String? userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetMeasurementsParams({
    this.userId,
    this.startDate,
    this.endDate,
  });
}