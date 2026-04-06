import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';
import '../../../measurements/domain/entities/measurement.dart';

class StatsPeriodSelector extends StatelessWidget {
  final MeasurementPeriod selectedPeriod;
  final ValueChanged<MeasurementPeriod> onChanged;

  const StatsPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButton<MeasurementPeriod>(
        value: selectedPeriod,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.backgroundSecondary,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textHint, size: 20),
        items: const [
          DropdownMenuItem(value: MeasurementPeriod.day, child: Text('День')),
          DropdownMenuItem(value: MeasurementPeriod.month, child: Text('Месяц')),
          DropdownMenuItem(value: MeasurementPeriod.year, child: Text('Год')),
          DropdownMenuItem(value: MeasurementPeriod.custom, child: Text('Период')),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}