import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

class DateRangePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onTap;

  const DateRangePicker({
    super.key,
    this.startDate,
    this.endDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startStr = startDate?.toString().split(' ').first ?? '00.00.0000';
    final endStr = endDate?.toString().split(' ').first ?? '00.00.0000';
    final rangeStr = '$startStr - $endStr';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                rangeStr,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
            ),
            const Icon(Icons.calendar_today, color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}