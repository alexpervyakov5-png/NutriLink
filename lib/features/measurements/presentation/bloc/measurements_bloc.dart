import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
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
    emit(state.copyWith(isLoading: true));
    
    final result = await getMeasurements(GetMeasurementsParams(
      startDate: event.startDate,
      endDate: event.endDate,
    ));
    
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: 'Ошибка загрузки')),
      (measurements) {
        final sorted = measurements..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
        emit(state.copyWith(
          isLoading: false,
          measurements: sorted,
        ));
      },
    );
  }

  Future<void> _onSaveMeasurements(
    SaveMeasurements event,
    Emitter<MeasurementsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    final measurement = Measurement(
      id: _uuid.v4(),
      userId: '',
      measuredAt: event.measuredAt,
      chestCm: event.chestCm,
      waistCm: event.waistCm,
      hipsCm: event.hipsCm,
    );
    
    final result = await saveMeasurement(SaveMeasurementParams(measurement: measurement));
    
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: 'Ошибка сохранения')),
      (_) {
        emit(state.copyWith(isLoading: false));
        add(LoadMeasurements());
      },
    );
  }

  Future<void> _onUpdateMeasurements(
    UpdateMeasurements event,
    Emitter<MeasurementsState> emit,
  ) async {
    debugPrint('🔍 BLoC: UpdateMeasurements id=${event.id}');
    
    final updatedMeasurements = state.measurements.map((m) {
      if (m.id == event.id) {
        return m.copyWith(
          measuredAt: event.measuredAt,
          chestCm: event.chestCm,
          waistCm: event.waistCm,
          hipsCm: event.hipsCm,
        );
      }
      return m;
    }).toList();
    
    emit(state.copyWith(measurements: updatedMeasurements));
    add(LoadMeasurements());
  }

  Future<void> _onDeleteMeasurement(
    DeleteMeasurement event,
    Emitter<MeasurementsState> emit,
  ) async {
    debugPrint('🔍 BLoC: DeleteMeasurement id=${event.id}');
    
    final updatedMeasurements = state.measurements.where((m) => m.id != event.id).toList();
    emit(state.copyWith(measurements: updatedMeasurements));
    add(LoadMeasurements());
  }
}