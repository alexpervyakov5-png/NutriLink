import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/usecases/get_measurements.dart';
import '../../domain/usecases/save_measurement.dart';
import 'measurements_event.dart';
import 'measurements_state.dart';

class MeasurementsBloc extends Bloc<MeasurementsEvent, MeasurementsState> {
  final GetMeasurements getMeasurements;
  final SaveMeasurement saveMeasurement;
  final Uuid _uuid = const Uuid();

  MeasurementsBloc({
    required this.getMeasurements,
    required this.saveMeasurement,
  }) : super(MeasurementsState.initial()) {
    on<LoadMeasurements>(_onLoadMeasurements);
    on<SaveMeasurements>(_onSaveMeasurements);
    on<UpdateMeasurements>(_onUpdateMeasurements);
    on<DeleteMeasurement>(_onDeleteMeasurement);
  }

  Future<void> _onLoadMeasurements(
    LoadMeasurements event,
    Emitter<MeasurementsState> emit,
  ) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('🔍 MeasurementsBloc: LoadMeasurements START');
    debugPrint('  startDate: ${event.startDate}');
    debugPrint('  endDate: ${event.endDate}');
    
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      debugPrint('⏳ Вызываем getMeasurements UseCase...');
      final result = await getMeasurements(GetMeasurementsParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ));
      
      debugPrint('✅ UseCase вернул результат за ${stopwatch.elapsedMilliseconds}ms');
      
      result.fold(
        (failure) {
          debugPrint('❌ MeasurementsBloc: Ошибка загрузки: $failure');
          debugPrint('   Type: ${failure.runtimeType}');
          debugPrint('   Message: ${failure.message}');
          
          final errorMsg = failure.message ?? 'Не удалось загрузить замеры';
          emit(state.copyWith(
            isLoading: false, 
            error: errorMsg,
            measurements: [],
          ));
        },
        (measurements) {
          debugPrint('✅ MeasurementsBloc: Получено ${measurements.length} замеров');
          
          if (measurements.isEmpty) {
            debugPrint('ℹ️ Список замеров пуст (это нормально для нового пользователя)');
          } else {
            final first = measurements.first;
            debugPrint('📊 Первый замер: ${first.weightKg}кг, ${first.chestCm}/${first.waistCm}/${first.hipsCm}');
          }
          
          final sorted = List<Measurement>.from(measurements)
            ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
          
          debugPrint('✅ Сортировка завершена за ${stopwatch.elapsedMilliseconds}ms');
          
          emit(state.copyWith(
            isLoading: false,
            measurements: sorted,
            error: null,
          ));
          
          debugPrint('🏁 LoadMeasurements завершено за ${stopwatch.elapsedMilliseconds}ms');
        },
      );
    } catch (e, stack) {
      debugPrint('❌ MeasurementsBloc: Критическая ошибка: $e');
      debugPrint('   Type: ${e.runtimeType}');
      debugPrint('📋 Stack: $stack');
      
      emit(state.copyWith(
        isLoading: false,
        error: 'Ошибка: ${e.toString()}',
        measurements: [],
      ));
    } finally {
      stopwatch.stop();
      debugPrint('⏱ Общее время: ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  Future<void> _onSaveMeasurements(
    SaveMeasurements event,
    Emitter<MeasurementsState> emit,
  ) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('🔍 MeasurementsBloc: SaveMeasurements START');
    
    emit(state.copyWith(isLoading: true));
    
    final measurement = Measurement(
      id: _uuid.v4(),
      userId: '',
      measuredAt: event.measuredAt,
      weightKg: event.weightKg,
      chestCm: event.chestCm,
      waistCm: event.waistCm,
      hipsCm: event.hipsCm,
    );
    
    try {
      debugPrint('⏳ Сохраняем замер...');
      final result = await saveMeasurement(SaveMeasurementParams(measurement: measurement));
      
      result.fold(
        (failure) {
          debugPrint('❌ MeasurementsBloc: Ошибка сохранения за ${stopwatch.elapsedMilliseconds}ms: $failure');
          final errorMsg = failure.message ?? 'Не удалось сохранить';
          emit(state.copyWith(
            isLoading: false, 
            error: errorMsg,
          ));
        },
        (_) {
          debugPrint('✅ MeasurementsBloc: Сохранение успешно за ${stopwatch.elapsedMilliseconds}ms!');
          emit(state.copyWith(isLoading: false, error: null));
          add(LoadMeasurements());
        },
      );
    } catch (e) {
      debugPrint('❌ MeasurementsBloc: Исключение при сохранении: $e');
      emit(state.copyWith(isLoading: false, error: 'Ошибка сети'));
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> _onUpdateMeasurements(
    UpdateMeasurements event,
    Emitter<MeasurementsState> emit,
  ) async {
    debugPrint('🔍 MeasurementsBloc: UpdateMeasurements вызван');
    
    emit(state.copyWith(isLoading: true));
    
    try {
      final measurement = Measurement(
        id: event.id,
        userId: '',
        measuredAt: event.measuredAt,
        weightKg: event.weightKg,
        chestCm: event.chestCm,
        waistCm: event.waistCm,
        hipsCm: event.hipsCm,
      );
      
      final result = await saveMeasurement(SaveMeasurementParams(measurement: measurement));
      
      result.fold(
        (failure) {
          debugPrint('❌ MeasurementsBloc: Ошибка обновления: $failure');
          final errorMsg = failure.message ?? 'Не удалось обновить';
          emit(state.copyWith(isLoading: false, error: errorMsg));
        },
        (_) {
          debugPrint('✅ MeasurementsBloc: Обновление успешно!');
          emit(state.copyWith(isLoading: false, error: null));
          add(LoadMeasurements());
        },
      );
    } catch (e) {
      debugPrint('❌ MeasurementsBloc: Исключение при обновлении: $e');
      emit(state.copyWith(isLoading: false, error: 'Ошибка сети'));
    }
  }

  Future<void> _onDeleteMeasurement(
    DeleteMeasurement event,
    Emitter<MeasurementsState> emit,
  ) async {
    debugPrint('🔍 MeasurementsBloc: DeleteMeasurement вызван, id=${event.id}');
    
    final updatedMeasurements = List<Measurement>.from(state.measurements)
      ..removeWhere((m) => m.id == event.id);
    
    emit(state.copyWith(measurements: updatedMeasurements));
    
    try {
      debugPrint('✅ MeasurementsBloc: Удаление успешно (оптимистично)');
    } catch (e) {
      debugPrint('❌ MeasurementsBloc: Ошибка при удалении: $e');
      add(LoadMeasurements());
    }
  }
}