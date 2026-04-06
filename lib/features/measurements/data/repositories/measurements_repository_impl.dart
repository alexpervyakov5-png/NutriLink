import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/repositories/measurements_repository.dart';
import '../datasources/measurements_mock_datasource.dart';
import '../models/measurement_model.dart';

class MeasurementsRepositoryImpl implements MeasurementsRepository {
  final MeasurementsMockDataSource mockDataSource;

  MeasurementsRepositoryImpl({required this.mockDataSource});

  @override
  Future<Either<Failure, List<Measurement>>> getMeasurements(
    MeasurementPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final measurements = await mockDataSource.getMeasurements(period, startDate, endDate);
      return Right(measurements);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveMeasurement(Measurement measurement) async {
    try {
      if (measurement is MeasurementModel) {
        await mockDataSource.saveMeasurement(measurement);
        return const Right(null);
      }
      return Left(ServerFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteMeasurement(String id) async {
    // TODO: Реализация
    return const Right(null);
  }
}