import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

class ProfileRadio<T> extends StatelessWidget {
  final String label;
  final T value;
  final T? groupValue;
  final IconData? icon;
  final ValueChanged<T?>? onChanged;

  const ProfileRadio({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<T>(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label, style: const TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: AppColors.accentLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}