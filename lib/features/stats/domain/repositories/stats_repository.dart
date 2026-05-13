import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stats.dart';

abstract class StatsRepository {
  Future<Either<Failure, NutritionStats>> getNutritionStats({
    DateTime? startDate,
    DateTime? endDate,
  });
}