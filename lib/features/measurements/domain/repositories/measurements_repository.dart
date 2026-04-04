import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/measurement.dart';

abstract class MeasurementsRepository {
  Future<Either<Failure, List<Measurement>>> getMeasurements();
  Future<Either<Failure, void>> addMeasurement(Measurement measurement);
}