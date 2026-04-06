import 'package:equatable/equatable.dart';
import '../../../measurements/domain/entities/measurement.dart';

abstract class StatsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStats extends StatsEvent {
  final MeasurementPeriod period;
  final DateTime? startDate;
  final DateTime? endDate;

  LoadStats({
    required this.period,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [period, startDate, endDate];
}

class StatsSelectPeriod extends StatsEvent {
  final MeasurementPeriod period;

  StatsSelectPeriod(this.period);

  @override
  List<Object> get props => [period];
}