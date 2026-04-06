import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/usecases/get_measurements.dart';
import '../../domain/usecases/save_measurement.dart';
import 'measurements_event.dart';
import 'measurements_state.dart';

class MeasurementsBloc extends Bloc<MeasurementsEvent, MeasurementsState> {
  final GetMeasurements getMeasurements;
  final SaveMeasurement saveMeasurement;

  MeasurementsBloc({
    required this.getMeasurements,
    required this.saveMeasurement,
  }) : super(const MeasurementsState()) {
    on<LoadMeasurements>(_onLoadMeasurements);
    on<UpdateMeasurementField>(_onUpdateMeasurementField);
    on<SaveMeasurements>(_onSaveMeasurements);
    on<SelectPeriod>(_onSelectPeriod);
  }

  Future<void> _onLoadMeasurements(LoadMeasurements event, Emitter<MeasurementsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await getMeasurements(GetMeasurementsParams(
      period: event.period,
      startDate: event.startDate,
      endDate: event.endDate,
    ));
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: 'Ошибка загрузки')),
      (measurements) {
        final latest = measurements.isNotEmpty ? measurements.first : null;
        emit(state.copyWith(
          measurements: measurements,
          currentMeasurement: latest,
          isLoading: false,
        ));
      },
    );
  }

  void _onUpdateMeasurementField(UpdateMeasurementField event, Emitter<MeasurementsState> emit) {
    if (state.currentMeasurement == null) {
      emit(state.copyWith(
        currentMeasurement: event.update(Measurement(id: '', date: DateTime.now())),
      ));
    } else {
      emit(state.copyWith(currentMeasurement: event.update(state.currentMeasurement!)));
    }
  }

  Future<void> _onSaveMeasurements(SaveMeasurements event, Emitter<MeasurementsState> emit) async {
    if (state.currentMeasurement == null) return;
    emit(state.copyWith(isSaving: true));
    final result = await saveMeasurement(state.currentMeasurement!);
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, error: 'Ошибка сохранения')),
      (_) => emit(state.copyWith(isSaving: false)),
    );
  }

  void _onSelectPeriod(SelectPeriod event, Emitter<MeasurementsState> emit) {
    emit(state.copyWith(selectedPeriod: event.period));
  }
}