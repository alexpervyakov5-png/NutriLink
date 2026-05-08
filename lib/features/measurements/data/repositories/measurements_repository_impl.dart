import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/repositories/measurements_repository.dart';
import '../datasources/measurements_supabase_datasource.dart';

class MeasurementsRepositoryImpl implements MeasurementsRepository {
  final MeasurementsSupabaseDataSource supabaseDataSource;

  MeasurementsRepositoryImpl({required this.supabaseDataSource});

  @override
  Future<Either<Failure, List<Measurement>>> getMeasurements(
    MeasurementPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final result = await supabaseDataSource.getMeasurements(
        period: period,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveMeasurement(Measurement measurement) async {
    try {
      await supabaseDataSource.saveMeasurement(measurement);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteMeasurement(String id) async {
    try {
      await supabaseDataSource.deleteMeasurement(id);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}