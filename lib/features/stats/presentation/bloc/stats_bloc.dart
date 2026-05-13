import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_nutrition_stats.dart';
import 'stats_event.dart';
import 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final GetNutritionStats getNutritionStats;

  StatsBloc({required this.getNutritionStats}) : super(StatsState.initial()) {
    on<LoadStats>(_onLoadStats);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await getNutritionStats(GetNutritionStatsParams(
      startDate: event.startDate,
      endDate: event.endDate,
    ));
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: 'Ошибка загрузки')),
      (stats) => emit(state.copyWith(stats: stats, isLoading: false)),
    );
  }
}