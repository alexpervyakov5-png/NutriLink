import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stats.dart';
import '../../../measurements/domain/entities/measurement.dart';

abstract class StatsRepository {
  Future<Either<Failure, NutritionStats>> getNutritionStats(
    MeasurementPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  );
}