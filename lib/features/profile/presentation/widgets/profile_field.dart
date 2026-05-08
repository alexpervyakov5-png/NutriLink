import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

class ProfileField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final bool readOnly;
  final Widget? suffixIcon;

  const ProfileField({
    super.key,
    required this.label,
    this.value,
    required this.hint,
    this.onChanged,
    this.onTap,
    this.keyboardType,
    this.readOnly = false,
    this.suffixIcon,
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
          // ✅ Оборачиваем в GestureDetector для надёжного клика
          child: GestureDetector(
            onTap: onTap,
            child: TextFormField(
              initialValue: value ?? '',
              readOnly: readOnly,
              keyboardType: keyboardType,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.textHint),
                suffixIcon: suffixIcon,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}