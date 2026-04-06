import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../bloc/measurements_bloc.dart';
import '../bloc/measurements_event.dart';
import '../bloc/measurements_state.dart';
import '../widgets/period_selector.dart';
import '../widgets/measurement_field.dart';
import '../widgets/date_range_picker.dart';

class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocBuilder<MeasurementsBloc, MeasurementsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ✅ Выбор периода
                PeriodSelector(
                  selectedPeriod: state.selectedPeriod,
                  onChanged: (period) => context.read<MeasurementsBloc>().add(
                    SelectPeriod(period),
                  ),
                ),
                const SizedBox(height: 16),
                // ✅ Выбор даты
                DateRangePicker(
                  startDate: state.startDate,
                  endDate: state.endDate,
                  onTap: () async {
                    final currentContext = context;
                    final range = await showDateRangePicker(
                      context: currentContext,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      initialDateRange: state.startDate != null && state.endDate != null
                          ? DateTimeRange(start: state.startDate!, end: state.endDate!)
                          : null,
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: AppColors.accentLight,
                            onPrimary: AppColors.background,
                            surface: AppColors.backgroundSecondary,
                            onSurface: AppColors.textPrimary,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (range != null && currentContext.mounted) {
                      currentContext.read<MeasurementsBloc>().add(
                        LoadMeasurements(
                          period: state.selectedPeriod,
                          startDate: range.start,
                          endDate: range.end,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                // ✅ Поля замеров
                _buildMeasurementFields(context, state),
                const SizedBox(height: 24),
                // ✅ Кнопка сохранения
                _buildSaveButton(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeasurementFields(BuildContext context, MeasurementsState state) {
    final measurement = state.currentMeasurement;
    return Column(
      children: [
        MeasurementField(
          label: 'Обхват груди, см',
          value: measurement?.chestCm?.toString(),
          hint: '0',
          onChanged: (value) => context.read<MeasurementsBloc>().add(
            UpdateMeasurementField((m) => m.copyWith(
              chestCm: double.tryParse(value),
            )),
          ),
        ),
        const SizedBox(height: 16),
        MeasurementField(
          label: 'Обхват талии, см',
          value: measurement?.waistCm?.toString(),
          hint: '0',
          onChanged: (value) => context.read<MeasurementsBloc>().add(
            UpdateMeasurementField((m) => m.copyWith(
              waistCm: double.tryParse(value),
            )),
          ),
        ),
        const SizedBox(height: 16),
        MeasurementField(
          label: 'Обхват бедер, см',
          value: measurement?.hipsCm?.toString(),
          hint: '0',
          onChanged: (value) => context.read<MeasurementsBloc>().add(
            UpdateMeasurementField((m) => m.copyWith(
              hipsCm: double.tryParse(value),
            )),
          ),
        ),
        const SizedBox(height: 16),
        MeasurementField(
          label: 'Вес, кг',
          value: measurement?.weightKg?.toString(),
          hint: '0.0',
          onChanged: (value) => context.read<MeasurementsBloc>().add(
            UpdateMeasurementField((m) => m.copyWith(
              weightKg: double.tryParse(value),
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, MeasurementsState state) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: state.isSaving ? null : () => context.read<MeasurementsBloc>().add(SaveMeasurements()),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: state.isSaving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Сохранить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}