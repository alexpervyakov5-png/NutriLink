import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/measurement.dart';

abstract class MeasurementsRepository {
  Future<Either<Failure, List<Measurement>>> getMeasurements(
    MeasurementPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  );
  Future<Either<Failure, void>> saveMeasurement(Measurement measurement);
  Future<Either<Failure, void>> deleteMeasurement(String id);
}