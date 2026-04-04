import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/meal.dart';

class MealItem extends StatelessWidget {
  final Meal meal;
  const MealItem({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.backgroundSecondary, width: 1))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(meal.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(meal.weight, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
        ])),
        Text('${meal.calories} ккал', style: const TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}