import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/repositories/measurements_repository.dart';

class SaveMeasurement implements UseCase<Either<Failure, void>, SaveMeasurementParams> {
  final MeasurementsRepository repository;

  SaveMeasurement(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveMeasurementParams params) async {
    return await repository.saveMeasurement(params.measurement);
  }
}

class SaveMeasurementParams {
  final Measurement measurement;

  SaveMeasurementParams({required this.measurement});
}