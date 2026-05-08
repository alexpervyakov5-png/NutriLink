import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/meal.dart';
import 'meal_item.dart';

class MealSection extends StatelessWidget {
  final String title;
  final String imagePath;
  final int totalCalories;
  final bool isExpanded;
  final VoidCallback onExpansionChanged;
  final VoidCallback? onCommentTap;
  final VoidCallback? onAddTap;  // ✅ Для кнопки "+"
  final List<Meal> items;

  const MealSection({
    super.key,
    required this.title,
    required this.imagePath,
    required this.totalCalories,
    required this.isExpanded,
    required this.onExpansionChanged,
    this.onCommentTap,
    this.onAddTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onExpansionChanged,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Изображение
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.accentTransparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        imagePath,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            _getFallbackIcon(title),
                            color: AppColors.accent,
                            size: 24,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentTransparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$totalCalories ккал',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isExpanded) ...[
                    // 💬 Кнопка комментария
                    if (onCommentTap != null)
                      _actionBtn(
                        Icons.chat_bubble_outline,
                        AppColors.backgroundSecondary,
                        onTap: onCommentTap,
                      ),
                    const SizedBox(width: 6),
                    // ➕ Кнопка добавления (вернули!)
                    if (onAddTap != null)
                      _actionBtn(
                        Icons.add,
                        AppColors.accent,
                        onTap: onAddTap,
                      ),
                  ],
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.backgroundSecondary),
            // ✅ Список добавленных блюд
            ...items.map((item) => MealItem(meal: item, onEditTap: onAddTap)),
          ],
        ],
      ),
    );
  }

  IconData _getFallbackIcon(String title) {
    switch (title) {
      case 'Завтрак': return Icons.free_breakfast;
      case 'Обед': return Icons.lunch_dining;
      case 'Ужин': return Icons.dinner_dining;
      case 'Перекус': return Icons.cookie;
      default: return Icons.restaurant;
    }
  }

  Widget _actionBtn(IconData icon, Color bg, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: bg == AppColors.accent ? Colors.white : AppColors.accent,
          size: 18,
        ),
      ),
    );
  }
}