import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_stats_data.dart';
import 'stats_event.dart';
import 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final GetStatsData getStatsData;

  StatsBloc({required this.getStatsData}) : super(StatsState.initial()) {
    on<LoadStats>(_onLoadStats);
    on<RefreshStats>(_onRefreshStats);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔍 StatsBloc: LoadStats START');
    debugPrint('  From: ${event.startDate}');
    debugPrint('  To: ${event.endDate}');
    debugPrint('  Current state: isLoading=${state.isLoading}');
    
    emit(state.copyWith(isLoading: true, error: null));

    try {
      debugPrint('⏳ Calling getStatsData UseCase...');
      
      final result = await getStatsData(GetStatsDataParams(
        startDate: event.startDate,
        endDate: event.endDate,
      )).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('❌ TIMEOUT after 10 seconds');
          throw TimeoutException('Загрузка статистики превысила 10 секунд');
        },
      );

      debugPrint('✅ UseCase completed');

      result.fold(
        (failure) {
          debugPrint('❌ Failure: $failure');
          debugPrint('   Type: ${failure.runtimeType}');
          emit(state.copyWith(
            isLoading: false,
            error: 'Ошибка: ${failure.toString()}',
          ));
        },
        (stats) {
          debugPrint('✅ SUCCESS!');
          debugPrint('  Nutrition: ${stats.nutrition.calories} kcal');
          debugPrint('  Weight points: ${stats.weightTrend.length}');
          debugPrint('  Streak: ${stats.streakDays} days');
          
          emit(state.copyWith(
            isLoading: false,
            stats: stats,
            error: null,
          ));
        },
      );
    } on TimeoutException catch (e) {
      debugPrint('❌ TimeoutException: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Превышено время ожидания',
      ));
    } catch (e, stack) {
      debugPrint('❌ EXCEPTION: $e');
      debugPrint('📋 Stack trace:');
      debugPrint(stack.toString());
      emit(state.copyWith(
        isLoading: false,
        error: 'Ошибка: ${e.toString()}',
      ));
    } finally {
      debugPrint('🏁 LoadStats FINISHED');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  Future<void> _onRefreshStats(RefreshStats event, Emitter<StatsState> emit) async {
    debugPrint('🔄 StatsBloc: RefreshStats START');
    
    emit(state.copyWith(isRefreshing: true));

    try {
      final result = await getStatsData(GetStatsDataParams(
        startDate: state.startDate,
        endDate: state.endDate,
      )).timeout(const Duration(seconds: 8));

      result.fold(
        (failure) => emit(state.copyWith(isRefreshing: false, error: 'Ошибка')),
        (stats) => emit(state.copyWith(isRefreshing: false, stats: stats, error: null)),
      );
    } catch (e) {
      emit(state.copyWith(isRefreshing: false, error: 'Ошибка обновления'));
    }
  }
}