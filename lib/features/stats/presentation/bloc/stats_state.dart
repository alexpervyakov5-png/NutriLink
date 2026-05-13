import 'package:equatable/equatable.dart';
import '../../domain/entities/stats.dart';

class StatsState extends Equatable {
  final bool isLoading;
  final String? error;
  final NutritionStats? stats;

  const StatsState({
    required this.isLoading,
    this.error,
    this.stats,
  });

  factory StatsState.initial() {
    return const StatsState(
      isLoading: false,
    );
  }

  StatsState copyWith({
    bool? isLoading,
    String? error,
    NutritionStats? stats,
  }) {
    return StatsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        stats,
      ];
}