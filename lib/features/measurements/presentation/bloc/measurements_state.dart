import 'package:equatable/equatable.dart';
import '../../domain/entities/measurement.dart';

class MeasurementsState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<Measurement> measurements;
  final DateTime selectedDate;

  const MeasurementsState({
    required this.isLoading,
    this.error,
    required this.measurements,
    required this.selectedDate,
  });

  factory MeasurementsState.initial() {
    return MeasurementsState(
      isLoading: false,
      measurements: [],
      selectedDate: DateTime.now(),
    );
  }

  MeasurementsState copyWith({
    bool? isLoading,
    String? error,
    List<Measurement>? measurements,
    DateTime? selectedDate,
  }) {
    return MeasurementsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      measurements: measurements ?? this.measurements,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        measurements,
        selectedDate,
      ];
}