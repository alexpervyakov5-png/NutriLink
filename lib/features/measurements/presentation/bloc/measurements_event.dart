import 'package:equatable/equatable.dart';
import '../../domain/entities/measurement.dart';

abstract class MeasurementsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMeasurements extends MeasurementsEvent {
  final MeasurementPeriod period;
  final DateTime? startDate;
  final DateTime? endDate;

  LoadMeasurements({
    required this.period,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [period, startDate, endDate];
}

class UpdateMeasurementField extends MeasurementsEvent {
  final Measurement Function(Measurement) update;

  UpdateMeasurementField(this.update);

  @override
  List<Object?> get props => [update];
}

class SaveMeasurements extends MeasurementsEvent {}

class SelectPeriod extends MeasurementsEvent {
  final MeasurementPeriod period;

  SelectPeriod(this.period);

  @override
  List<Object?> get props => [period];
}