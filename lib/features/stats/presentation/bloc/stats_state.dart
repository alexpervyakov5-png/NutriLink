import 'package:equatable/equatable.dart';
import '../../domain/entities/stats.dart';
import '../../../measurements/domain/entities/measurement.dart';

class StatsState extends Equatable {
  final NutritionStats? stats;
  final MeasurementPeriod selectedPeriod;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;
  final String? error;

  const StatsState({
    this.stats,
    this.selectedPeriod = MeasurementPeriod.day,
    this.startDate,
    this.endDate,
    this.isLoading = false,
    this.error,
  });

  StatsState copyWith({
    NutritionStats? stats,
    MeasurementPeriod? selectedPeriod,
    DateTime? startDate,
    DateTime? endDate,
    bool? isLoading,
    String? error,
  }) {
    return StatsState(
      stats: stats ?? this.stats,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        selectedPeriod,
        startDate,
        endDate,
        isLoading,
        error,
      ];
}