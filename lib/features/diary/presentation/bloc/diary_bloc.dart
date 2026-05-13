import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart'; // ✅ Обязательно для Either
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
    debugPrint('🔍 BLoC: LoadDiaryData для ${event.date}');
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      // ✅ Загружаем последовательно для простоты и отладки
      final goalsResult = await repository.getDailyGoals(event.date);
      final breakfastResult = await repository.getMealsByType(MealType.breakfast, event.date);
      final lunchResult = await repository.getMealsByType(MealType.lunch, event.date);
      final dinnerResult = await repository.getMealsByType(MealType.dinner, event.date);
      final snackResult = await repository.getMealsByType(MealType.snack, event.date);

      debugPrint('✅ BLoC: Все данные загружены');

      // ✅ Проверяем цели
      DailyGoals? goals;
      goalsResult.fold(
        (failure) {
          debugPrint('❌ Ошибка загрузки целей: $failure');
          goals = DailyGoals(
            proteinTarget: 100,
            fatsTarget: 65,
            carbsTarget: 285,
            caloriesTarget: 2500,
            proteinCurrent: 0,
            fatsCurrent: 0,
            carbsCurrent: 0,
            caloriesCurrent: 0,
          );
        },
        (g) {
          debugPrint('✅ Цели загружены: ${g.caloriesTarget} ккал');
          goals = g;
        },
      );

      // ✅ Загружаем приёмы пищи
      final meals = <MealType, List<Meal>>{};
      
      breakfastResult.fold(
        (failure) {
          debugPrint('⚠️ Ошибка загрузки завтрака: $failure');
          meals[MealType.breakfast] = [];
        },
        (breakfast) {
          debugPrint('✅ Завтрак: ${breakfast.length} блюд');
          meals[MealType.breakfast] = breakfast;
        },
      );

      lunchResult.fold(
        (failure) {
          debugPrint('⚠️ Ошибка загрузки обеда: $failure');
          meals[MealType.lunch] = [];
        },
        (lunch) {
          debugPrint('✅ Обед: ${lunch.length} блюд');
          meals[MealType.lunch] = lunch;
        },
      );

      dinnerResult.fold(
        (failure) {
          debugPrint('⚠️ Ошибка загрузки ужина: $failure');
          meals[MealType.dinner] = [];
        },
        (dinner) {
          debugPrint('✅ Ужин: ${dinner.length} блюд');
          meals[MealType.dinner] = dinner;
        },
      );

      snackResult.fold(
        (failure) {
          debugPrint('⚠️ Ошибка загрузки перекусов: $failure');
          meals[MealType.snack] = [];
        },
        (snack) {
          debugPrint('✅ Перекусы: ${snack.length} блюд');
          meals[MealType.snack] = snack;
        },
      );

      // ✅ Emit состояния
      emit(state.copyWith(
        selectedDate: event.date,
        goals: goals,
        meals: meals,
        isLoading: false,
        error: null,
      ));
      
      debugPrint('✅ BLoC: Состояние обновлено');
      
    } catch (e, stack) {
      debugPrint('❌ BLoC: Критическая ошибка: $e');
      debugPrint('📋 Stack: $stack');
      emit(state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки: ${e.toString()}',
      ));
    }
  }

  void _onToggleMealSection(ToggleMealSection event, Emitter<DiaryState> emit) {
    final current = state.expandedSections[event.mealType] ?? false;
    final updated = Map<MealType, bool>.from(state.expandedSections)
      ..[event.mealType] = !current;
    emit(state.copyWith(expandedSections: updated));
  }

  Future<void> _onAddMealItem(AddMealItem event, Emitter<DiaryState> emit) async {
    debugPrint('🔍 BLoC: AddMealItem - ${event.productName}');
    
    // Оптимистичное обновление UI
    final newMeal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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

    final currentMeals = state.meals[event.mealType] ?? [];
    final updatedMeals = Map<MealType, List<Meal>>.from(state.meals)
      ..[event.mealType] = [...currentMeals, newMeal];

    final currentGoals = state.goals;
    // ✅ Исправлено: currentGoals не может быть null здесь, т.к. мы его загрузили
    final updatedGoals = currentGoals!.copyWith(
      caloriesCurrent: currentGoals.caloriesCurrent + event.calories,
      proteinCurrent: currentGoals.proteinCurrent + event.protein,
      fatsCurrent: currentGoals.fatsCurrent + event.fats,
      carbsCurrent: currentGoals.carbsCurrent + event.carbs,
    );

    emit(state.copyWith(meals: updatedMeals, goals: updatedGoals));

    // Сохранение в БД
    debugPrint('📤 BLoC: Сохраняем в БД...');
    final result = await repository.addMealItem(newMeal, event.productId);

    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Ошибка сохранения: $failure');
        emit(state.copyWith(error: 'Не удалось сохранить'));
        // Откат изменений
        add(LoadDiaryData(date: state.selectedDate));
      },
      (_) {
        debugPrint('✅ BLoC: Сохранение успешно');
        // Перезагружаем данные
        add(LoadDiaryData(date: state.selectedDate));
      },
    );
  }

  Future<void> _onUpdateMealItem(UpdateMealItem event, Emitter<DiaryState> emit) async {
    // TODO: Реализовать обновление
    debugPrint('⚠️ UpdateMealItem not implemented yet');
  }

  Future<void> _onRemoveMealItem(RemoveMealItem event, Emitter<DiaryState> emit) async {
    // TODO: Реализовать удаление
    debugPrint('⚠️ RemoveMealItem not implemented yet');
  }

  void _onAddComment(AddComment event, Emitter<DiaryState> emit) {
    // TODO: Реализовать добавление комментария
    debugPrint('⚠️ AddComment not implemented yet');
  }
}