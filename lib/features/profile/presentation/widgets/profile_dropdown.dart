import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

class ProfileDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String hint;

  const ProfileDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    this.onChanged,
    this.hint = 'Выберите',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              dropdownColor: AppColors.card,
              style: const TextStyle(color: AppColors.textPrimary),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textHint),
              items: items,
              onChanged: onChanged,
              hint: Text(hint, style: const TextStyle(color: AppColors.textHint)),
            ),
          ),
        ),
      ],
    );
  }
}