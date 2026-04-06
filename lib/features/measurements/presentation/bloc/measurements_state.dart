import 'package:equatable/equatable.dart';
import '../../domain/entities/measurement.dart';

class MeasurementsState extends Equatable {
  final List<Measurement> measurements;
  final Measurement? currentMeasurement;
  final MeasurementPeriod selectedPeriod;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const MeasurementsState({
    this.measurements = const [],
    this.currentMeasurement,
    this.selectedPeriod = MeasurementPeriod.day,
    this.startDate,
    this.endDate,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  MeasurementsState copyWith({
    List<Measurement>? measurements,
    Measurement? currentMeasurement,
    MeasurementPeriod? selectedPeriod,
    DateTime? startDate,
    DateTime? endDate,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return MeasurementsState(
      measurements: measurements ?? this.measurements,
      currentMeasurement: currentMeasurement ?? this.currentMeasurement,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        measurements,
        currentMeasurement,
        selectedPeriod,
        startDate,
        endDate,
        isLoading,
        isSaving,
        error,
      ];
}