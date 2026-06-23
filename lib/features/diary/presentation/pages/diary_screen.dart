import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/meal.dart';
import '../bloc/diary_bloc.dart';
import '../bloc/diary_event.dart';
import '../bloc/diary_state.dart';
import '../widgets/goals_section.dart';
import '../widgets/meal_section.dart';
import '../widgets/comment_bottom_sheet.dart';
import 'add_food_screen.dart';
import '../../domain/entities/meal_type.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  // Пути к изображениям
  static const _imageBreakfast = 'assets/images/breakfast.png';
  static const _imageLunch = 'assets/images/lunch.png';
  static const _imageDinner = 'assets/images/dinner.png';
  static const _imageSnack = 'assets/images/snack.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(context),
          BlocBuilder<DiaryBloc, DiaryState>(
            builder: (context, state) {
              if (state.isLoading || state.goals == null) {
                return const SizedBox.shrink();
              }
              return GoalsSection(goals: state.goals!);
            },
          ),
          Expanded(
            child: BlocBuilder<DiaryBloc, DiaryState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(child: Text('Ошибка: ${state.error}'));
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    MealSection(
                      title: 'Завтрак',
                      imagePath: _imageBreakfast,
                      totalCalories: _calc(state.meals[MealType.breakfast]),
                      isExpanded: state.expandedSections[MealType.breakfast] ?? false,
                      onExpansionChanged: () => context.read<DiaryBloc>().add(
                        ToggleMealSection(mealType: MealType.breakfast),
                      ),
                      onCommentTap: () => _showCommentSheet(context, MealType.breakfast, state),
                      onAddTap: () => _navigateToAddFood(context, MealType.breakfast),
                      items: state.meals[MealType.breakfast] ?? [],
                    ),
                    MealSection(
                      title: 'Обед',
                      imagePath: _imageLunch,
                      totalCalories: _calc(state.meals[MealType.lunch]),
                      isExpanded: state.expandedSections[MealType.lunch] ?? false,
                      onExpansionChanged: () => context.read<DiaryBloc>().add(
                        ToggleMealSection(mealType: MealType.lunch),
                      ),
                      onCommentTap: () => _showCommentSheet(context, MealType.lunch, state),
                      onAddTap: () => _navigateToAddFood(context, MealType.lunch),
                      items: state.meals[MealType.lunch] ?? [],
                    ),
                    MealSection(
                      title: 'Ужин',
                      imagePath: _imageDinner,
                      totalCalories: _calc(state.meals[MealType.dinner]),
                      isExpanded: state.expandedSections[MealType.dinner] ?? false,
                      onExpansionChanged: () => context.read<DiaryBloc>().add(
                        ToggleMealSection(mealType: MealType.dinner),
                      ),
                      onCommentTap: () => _showCommentSheet(context, MealType.dinner, state),
                      onAddTap: () => _navigateToAddFood(context, MealType.dinner),
                      items: state.meals[MealType.dinner] ?? [],
                    ),
                    MealSection(
                      title: 'Перекус',
                      imagePath: _imageSnack,
                      totalCalories: _calc(state.meals[MealType.snack]),
                      isExpanded: state.expandedSections[MealType.snack] ?? false,
                      onExpansionChanged: () => context.read<DiaryBloc>().add(
                        ToggleMealSection(mealType: MealType.snack),
                      ),
                      onCommentTap: () => _showCommentSheet(context, MealType.snack, state),
                      onAddTap: () => _navigateToAddFood(context, MealType.snack),
                      items: state.meals[MealType.snack] ?? [],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.backgroundSecondary, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('День', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          
          // ✅ ДИНАМИЧЕСКАЯ ДАТА из состояния BLoC
          BlocBuilder<DiaryBloc, DiaryState>(
            builder: (context, state) {
              final formattedDate = DateFormat('dd MMMM yyyy', 'ru_RU').format(state.selectedDate);
              return Text(
                formattedDate,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          
          GestureDetector(
            onTap: () async {
              final currentDate = context.read<DiaryBloc>().state.selectedDate;
              final date = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: AppColors.accentLight,
                        onPrimary: AppColors.background,
                        surface: AppColors.backgroundSecondary,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (!context.mounted) return;
              if (date != null) {
                context.read<DiaryBloc>().add(LoadDiaryData(date: date));
              }
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.calendar_today, color: AppColors.textPrimary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Показываем полустраницу с комментарием (теперь передаём meals)
  void _showCommentSheet(BuildContext context, MealType mealType, DiaryState state) {
    final mealsOfType = state.meals[mealType] ?? [];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CommentBottomSheet(
        mealType: mealType,
        meals: mealsOfType,
      ),
    );
  }

  // ✅ Переход на страницу добавления продуктов
  void _navigateToAddFood(BuildContext context, MealType mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodScreen(mealType: mealType),
      ),
    );
  }

  int _calc(List<Meal>? meals) {
    if (meals == null || meals.isEmpty) return 0;
    return meals.fold<int>(0, (sum, meal) => sum + meal.calories);
  }
}