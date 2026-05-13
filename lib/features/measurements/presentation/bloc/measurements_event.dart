import 'package:equatable/equatable.dart';

abstract class MeasurementsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMeasurements extends MeasurementsEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  
  LoadMeasurements({this.startDate, this.endDate});
  
  @override
  List<Object?> get props => [startDate, endDate];
}

class SaveMeasurements extends MeasurementsEvent {
  final DateTime measuredAt;
  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;
  
  SaveMeasurements({
    required this.measuredAt,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
  });
  
  @override
  List<Object?> get props => [measuredAt, chestCm, waistCm, hipsCm];
}

class UpdateMeasurements extends MeasurementsEvent {
  final String id;
  final DateTime measuredAt;
  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;
  
  UpdateMeasurements({
    required this.id,
    required this.measuredAt,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
  });
  
  @override
  List<Object?> get props => [id, measuredAt, chestCm, waistCm, hipsCm];
}

class DeleteMeasurement extends MeasurementsEvent {
  final String id;
  
  DeleteMeasurement({required this.id});
  
  @override
  List<Object?> get props => [id];
}