import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/meal.dart';
import '../bloc/diary_bloc.dart';
import '../bloc/diary_event.dart';
import '../bloc/diary_state.dart';
import '../widgets/goals_section.dart';
import '../widgets/meal_section.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  // ✅ Пути к изображениям
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
          // ✅ Компактный хедер с календарём
          _buildHeader(context),
          // ✅ Цели (отдельный виджет)
          BlocBuilder<DiaryBloc, DiaryState>(
            builder: (context, state) {
              if (state.isLoading || state.goals == null) {
                return const SizedBox.shrink();
              }
              return GoalsSection(goals: state.goals!);
            },
          ),
          // ✅ Список приёмов пищи
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

  // 📅 Компактный хедер с календарём
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.backgroundSecondary,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'День',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const Text(
            '31 января 2026 г',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: AppColors.accentLight,
                      onPrimary: AppColors.background,
                      surface: AppColors.backgroundSecondary,
                      onSurface: AppColors.textPrimary,
                    ),
                  ),
                  child: child!,
                ),
              );
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
              child: const Icon(
                Icons.calendar_today,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calc(List<Meal>? meals) {
    if (meals == null || meals.isEmpty) return 0;
    return meals.fold<int>(0, (sum, meal) => sum + meal.calories);
  }
}