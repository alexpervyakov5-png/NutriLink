import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

class StatsRow extends StatelessWidget {
  final String label;
  final String value;
  final String percent;
  final Color color;
  final IconData icon;
  final bool isTotal;

  const StatsRow({
    super.key,
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    required this.icon,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Иконка
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          
          // Название
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: isTotal ? 15 : 14,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          
          // Значение
          Text(
            value,
            style: TextStyle(
              color: isTotal ? AppColors.accentLight : color,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Процент
          SizedBox(
            width: 50,
            child: Text(
              percent,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isTotal ? AppColors.textPrimary : AppColors.textHint,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}