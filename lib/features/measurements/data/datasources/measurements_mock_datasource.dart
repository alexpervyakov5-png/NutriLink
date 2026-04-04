import '../../domain/entities/measurement.dart';

abstract class MeasurementsMockDataSource {
  Future<List<Measurement>> getMeasurements();
}

class MeasurementsMockDataSourceImpl implements MeasurementsMockDataSource {
  @override
  Future<List<Measurement>> getMeasurements() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Measurement(id: '1', date: DateTime.now().subtract(const Duration(days: 7)), weight: 75.5, waist: 85),
      Measurement(id: '2', date: DateTime.now().subtract(const Duration(days: 14)), weight: 76.2, waist: 86),
    ];
  }
}