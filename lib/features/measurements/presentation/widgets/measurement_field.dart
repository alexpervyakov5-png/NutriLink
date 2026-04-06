import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

class MeasurementField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEdit;

  const MeasurementField({
    super.key,
    required this.label,
    this.value,
    required this.hint,
    this.onChanged,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textHint),
              suffixIcon: IconButton(
                icon: const Icon(Icons.edit, color: AppColors.textHint, size: 20),
                onPressed: onEdit,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}