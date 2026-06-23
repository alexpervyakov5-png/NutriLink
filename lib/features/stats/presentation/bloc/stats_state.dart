import 'package:equatable/equatable.dart';
import '../../domain/entities/stats.dart';

class StatsState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final StatsData? stats;
  final DateTime startDate;
  final DateTime endDate;

  const StatsState({
    required this.isLoading,
    required this.isRefreshing,
    this.error,
    this.stats,
    required this.startDate,
    required this.endDate,
  });

  factory StatsState.initial() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, now.day);
    
    return StatsState(
      isLoading: true,
      isRefreshing: false,
      startDate: start,
      endDate: now,
    );
  }

  StatsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    StatsData? stats,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return StatsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      stats: stats ?? this.stats,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
        isLoading, isRefreshing, error, stats, startDate, endDate,
      ];
}