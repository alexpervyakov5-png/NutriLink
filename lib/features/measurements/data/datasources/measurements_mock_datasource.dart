import '../../domain/entities/measurement.dart';
import '../models/measurement_model.dart';

abstract class MeasurementsMockDataSource {
  Future<List<MeasurementModel>> getMeasurements(
    MeasurementPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  );
  Future<void> saveMeasurement(MeasurementModel measurement);
}

class MeasurementsMockDataSourceImpl implements MeasurementsMockDataSource {
  List<MeasurementModel> _cachedMeasurements = [];

  @override
  Future<List<MeasurementModel>> getMeasurements(
    MeasurementPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_cachedMeasurements.isEmpty) {
      _cachedMeasurements = [
        MeasurementModel(
          id: '1',
          date: DateTime.now().subtract(const Duration(days: 7)),
          chestCm: 90,
          waistCm: 60,
          hipsCm: 90,
          weightKg: 49.3,
        ),
        MeasurementModel(
          id: '2',
          date: DateTime.now().subtract(const Duration(days: 14)),
          chestCm: 91,
          waistCm: 61,
          hipsCm: 91,
          weightKg: 50.1,
        ),
      ];
    }

    return _cachedMeasurements;
  }

  @override
  Future<void> saveMeasurement(MeasurementModel measurement) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cachedMeasurements.insert(0, measurement);
  }
}