import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_nutrition_stats.dart';
import 'stats_event.dart';
import 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final GetNutritionStats getNutritionStats;

  StatsBloc({required this.getNutritionStats}) : super(const StatsState()) {
    on<LoadStats>(_onLoadStats);
    on<StatsSelectPeriod>(_onSelectPeriod);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await getNutritionStats(GetNutritionStatsParams(
      period: event.period,
      startDate: event.startDate,
      endDate: event.endDate,
    ));
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: 'Ошибка загрузки')),
      (stats) => emit(state.copyWith(stats: stats, isLoading: false)),
    );
  }

  void _onSelectPeriod(StatsSelectPeriod event, Emitter<StatsState> emit) {
    emit(state.copyWith(selectedPeriod: event.period));
  }
}