import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/daily_goals.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/repositories/diary_repository.dart';
import 'diary_event.dart';
import 'diary_state.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  final DiaryRepository repository;

  DiaryBloc({required this.repository}) : super(DiaryState.initial()) {
    on<LoadDiaryData>(_onLoadDiaryData);
    on<ToggleMealSection>(_onToggleMealSection);
    on<AddMealItem>(_onAddMealItem);
    on<UpdateMealItem>(_onUpdateMealItem);
    on<RemoveMealItem>(_onRemoveMealItem);
    on<AddComment>(_onAddComment);
  }

  Future<void> _onLoadDiaryData(LoadDiaryData event, Emitter<DiaryState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final goalsResult = await repository.getDailyGoals(event.date);
      final breakfastResult = await repository.getMealsByType(MealType.breakfast, event.date);
      final lunchResult = await repository.getMealsByType(MealType.lunch, event.date);
      final dinnerResult = await repository.getMealsByType(MealType.dinner, event.date);
      final snackResult = await repository.getMealsByType(MealType.snack, event.date);

      goalsResult.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: 'Ошибка загрузки целей')),
        (goals) {
          breakfastResult.fold((_) => null, (breakfast) {
            lunchResult.fold((_) => null, (lunch) {
              dinnerResult.fold((_) => null, (dinner) {
                snackResult.fold((_) => null, (snack) {
                  emit(state.copyWith(
                    selectedDate: event.date,
                    goals: goals,
                    meals: {
                      MealType.breakfast: breakfast,
                      MealType.lunch: lunch,
                      MealType.dinner: dinner,
                      MealType.snack: snack,
                    },
                    isLoading: false,
                  ));
                });
              });
            });
          });
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Ошибка: ${e.toString()}'));
    }
  }

  void _onToggleMealSection(ToggleMealSection event, Emitter<DiaryState> emit) {
    final current = state.expandedSections[event.mealType] ?? false;
    final updated = Map<MealType, bool>.from(state.expandedSections)..[event.mealType] = !current;
    emit(state.copyWith(expandedSections: updated));
  }

  // ✅ ДОБАВЛЕНИЕ С СОХРАНЕНИЕМ В БД
  Future<void> _onAddMealItem(AddMealItem event, Emitter<DiaryState> emit) async {
    final newMeal = Meal(
      id: event.productId,
      name: event.productName,
      weight: event.weight,
      calories: event.calories,
      protein: event.protein,
      fats: event.fats,
      carbs: event.carbs,
      mealType: event.mealType,
      createdAt: DateTime.now(),
      comment: null,
    );

    // 1. Обновляем UI сразу (оптимистичное обновление)
    final currentMeals = state.meals[event.mealType] ?? [];
    final updatedMeals = Map<MealType, List<Meal>>.from(state.meals)..[event.mealType] = [...currentMeals, newMeal];
    final currentGoals = state.goals;
    final updatedGoals = currentGoals?.copyWith(
      caloriesCurrent: (currentGoals.caloriesCurrent ?? 0) + event.calories,
      proteinCurrent: (currentGoals.proteinCurrent ?? 0) + event.protein,
      fatsCurrent: (currentGoals.fatsCurrent ?? 0) + event.fats,
      carbsCurrent: (currentGoals.carbsCurrent ?? 0) + event.carbs,
    );
    emit(state.copyWith(meals: updatedMeals, goals: updatedGoals));

    // 2. Сохраняем в Supabase
    final result = await repository.addMeal(newMeal);
    result.fold(
      (failure) => emit(state.copyWith(error: 'Не удалось сохранить в БД')),
      (_) => null, // Успешно сохранено
    );
  }

  // ✅ ОБНОВЛЕНИЕ С СОХРАНЕНИЕМ В БД
  Future<void> _onUpdateMealItem(UpdateMealItem event, Emitter<DiaryState> emit) async {
    final currentMeals = state.meals[event.mealType] ?? [];
    final updatedMeals = currentMeals.map((meal) {
      if (meal.id == event.mealId) {
        return meal.copyWith(weight: event.weight, calories: event.calories, protein: event.protein, fats: event.fats, carbs: event.carbs);
      }
      return meal;
    }).toList();
    emit(state.copyWith(meals: {...state.meals, event.mealType: updatedMeals}));

    final mealToUpdate = updatedMeals.firstWhere((m) => m.id == event.mealId);
    await repository.updateMeal(mealToUpdate);
  }

  // ✅ УДАЛЕНИЕ С СОХРАНЕНИЕМ В БД
  Future<void> _onRemoveMealItem(RemoveMealItem event, Emitter<DiaryState> emit) async {
    final currentMeals = state.meals[event.mealType] ?? [];
    final removedMeal = currentMeals.firstWhere((meal) => meal.id == event.mealId, orElse: Meal.empty);
    final updatedMeals = currentMeals.where((meal) => meal.id != event.mealId).toList();
    emit(state.copyWith(meals: {...state.meals, event.mealType: updatedMeals}));

    await repository.deleteMeal(event.mealId);
  }

  void _onAddComment(AddComment event, Emitter<DiaryState> emit) {
    // TODO: Реализовать сохранение комментария
    emit(state.copyWith());
  }
}