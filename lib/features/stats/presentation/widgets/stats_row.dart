import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

class StatsRow extends StatelessWidget {
  final String label;
  final String value;
  final String percent;
  final Color color;
  final String imagePath;  // ✅ Путь к изображению

  const StatsRow({
    super.key,
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // ✅ Изображение
          Container(
            width: 24,
            height: 24,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback если изображение не найдено
                return Icon(
                  _getFallbackIcon(label),
                  color: color,
                  size: 20,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 50,
            child: Text(
              percent,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Fallback иконки
  IconData _getFallbackIcon(String label) {
    switch (label) {
      case 'Белки':
        return Icons.local_fire_department;
      case 'Жиры':
        return Icons.water_drop;
      case 'Углеводы':
        return Icons.grain;
      case 'Калории':
        return Icons.bolt;
      default:
        return Icons.info;
    }
  }
}