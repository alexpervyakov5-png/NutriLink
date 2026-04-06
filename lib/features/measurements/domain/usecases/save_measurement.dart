import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/measurement.dart';
import '../repositories/measurements_repository.dart';

class SaveMeasurement implements UseCase<Either<Failure, void>, Measurement> {
  final MeasurementsRepository repository;
  SaveMeasurement(this.repository);

  @override
  Future<Either<Failure, void>> call(Measurement params) async {
    return await repository.saveMeasurement(params);
  }
}