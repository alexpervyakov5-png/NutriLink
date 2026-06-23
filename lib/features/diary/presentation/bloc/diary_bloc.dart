import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/daily_goals.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/repositories/diary_repository.dart';
import 'diary_event.dart';
import 'diary_state.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  final DiaryRepository repository;
  bool _isLoading = false;

  DiaryBloc({required this.repository}) : super(DiaryState.initial()) {
    on<LoadDiaryData>(_onLoadDiaryData);
    on<ToggleMealSection>(_onToggleMealSection);
    on<AddMealItem>(_onAddMealItem);
    on<UpdateMealItem>(_onUpdateMealItem);
    on<RemoveMealItem>(_onRemoveMealItem);
    on<AddComment>(_onAddComment);
  }

  Future<void> _onLoadDiaryData(LoadDiaryData event, Emitter<DiaryState> emit) async {
    if (_isLoading) return;
    _isLoading = true;

    debugPrint('🔍 LoadDiaryData: ${event.date}');
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final results = await Future.wait([
        repository.getDailyGoals(event.date).timeout(const Duration(seconds: 10)),
        repository.getMealsByType(MealType.breakfast, event.date).timeout(const Duration(seconds: 10)),
        repository.getMealsByType(MealType.lunch, event.date).timeout(const Duration(seconds: 10)),
        repository.getMealsByType(MealType.dinner, event.date).timeout(const Duration(seconds: 10)),
        repository.getMealsByType(MealType.snack, event.date).timeout(const Duration(seconds: 10)),
      ]);

      final goalsResult = results[0] as Either;
      final breakfastResult = results[1] as Either;
      final lunchResult = results[2] as Either;
      final dinnerResult = results[3] as Either;
      final snackResult = results[4] as Either;

      DailyGoals goals = const DailyGoals.empty();
      goalsResult.fold((_) => {}, (g) => goals = g);

      final meals = <MealType, List<Meal>>{};
      breakfastResult.fold((_) => meals[MealType.breakfast] = [], (b) => meals[MealType.breakfast] = b);
      lunchResult.fold((_) => meals[MealType.lunch] = [], (l) => meals[MealType.lunch] = l);
      dinnerResult.fold((_) => meals[MealType.dinner] = [], (d) => meals[MealType.dinner] = d);
      snackResult.fold((_) => meals[MealType.snack] = [], (s) => meals[MealType.snack] = s);

      emit(state.copyWith(
        selectedDate: event.date,
        goals: goals,
        meals: meals,
        isLoading: false,
        error: null,
      ));

      debugPrint('✅ LoadDiaryData OK');
    } catch (e) {
      debugPrint('❌ LoadDiaryData ERROR: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки',
        goals: const DailyGoals.empty(),
        meals: {
          MealType.breakfast: [],
          MealType.lunch: [],
          MealType.dinner: [],
          MealType.snack: [],
        },
      ));
    } finally {
      _isLoading = false;
    }
  }

  void _onToggleMealSection(ToggleMealSection event, Emitter<DiaryState> emit) {
    final current = state.expandedSections[event.mealType] ?? false;
    final updated = Map<MealType, bool>.from(state.expandedSections)..[event.mealType] = !current;
    emit(state.copyWith(expandedSections: updated));
  }

  Future<void> _onAddMealItem(AddMealItem event, Emitter<DiaryState> emit) async {
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
      comment: event.comment,
    );

    final currentMeals = state.meals[event.mealType] ?? [];
    final updatedMeals = Map<MealType, List<Meal>>.from(state.meals)
      ..[event.mealType] = [...currentMeals, newMeal];

    final currentGoals = state.goals!;
    final updatedGoals = currentGoals.copyWith(
      caloriesCurrent: currentGoals.caloriesCurrent + event.calories,
      proteinCurrent: currentGoals.proteinCurrent + event.protein,
      fatsCurrent: currentGoals.fatsCurrent + event.fats,
      carbsCurrent: currentGoals.carbsCurrent + event.carbs,
    );

    emit(state.copyWith(meals: updatedMeals, goals: updatedGoals));

    try {
      final result = await repository.addMealItem(newMeal, event.productId);
      result.fold(
        (failure) => debugPrint('❌ Save error: $failure'),
        (_) => add(LoadDiaryData(date: state.selectedDate)),
      );
    } catch (e) {
      debugPrint('❌ Network error: $e');
    }
  }

  Future<void> _onUpdateMealItem(UpdateMealItem event, Emitter<DiaryState> emit) async {
    final currentMeals = state.meals[event.mealType] ?? [];
    final updatedMealsList = currentMeals.map((meal) {
      if (meal.id == event.mealId) {
        return meal.copyWith(
          weight: event.weight,
          calories: event.calories,
          protein: event.protein,
          fats: event.fats,
          carbs: event.carbs,
          comment: event.comment,
        );
      }
      return meal;
    }).toList();

    final updatedMeals = Map<MealType, List<Meal>>.from(state.meals)
      ..[event.mealType] = updatedMealsList;

    emit(state.copyWith(meals: updatedMeals));

    try {
      final updatedMeal = updatedMealsList.firstWhere((m) => m.id == event.mealId);
      final result = await repository.updateMealItem(updatedMeal);
      result.fold(
        (failure) => debugPrint('❌ Update error: $failure'),
        (_) => add(LoadDiaryData(date: state.selectedDate)),
      );
    } catch (e) {
      add(LoadDiaryData(date: state.selectedDate));
    }
  }

  Future<void> _onRemoveMealItem(RemoveMealItem event, Emitter<DiaryState> emit) async {
    final currentMeals = state.meals[event.mealType] ?? [];
    final updatedMealsList = currentMeals.where((m) => m.id != event.mealId).toList();
    final updatedMeals = Map<MealType, List<Meal>>.from(state.meals)
      ..[event.mealType] = updatedMealsList;

    emit(state.copyWith(meals: updatedMeals));

    try {
      final result = await repository.deleteMealItem(event.mealId);
      result.fold(
        (failure) => debugPrint('❌ Delete error: $failure'),
        (_) => add(LoadDiaryData(date: state.selectedDate)),
      );
    } catch (e) {
      add(LoadDiaryData(date: state.selectedDate));
    }
  }

  Future<void> _onAddComment(AddComment event, Emitter<DiaryState> emit) async {
    String? targetMealId = event.mealId;
    if (targetMealId == null || targetMealId.isEmpty) {
      final mealsOfType = state.meals[event.mealType] ?? [];
      if (mealsOfType.isNotEmpty) targetMealId = mealsOfType.first.id;
    }

    if (targetMealId == null || targetMealId.isEmpty) return;

    final currentMeals = state.meals[event.mealType] ?? [];
    final updatedMealsList = currentMeals.map((meal) {
      if (meal.id == targetMealId) {
        return meal.copyWith(comment: event.text);
      }
      return meal;
    }).toList();

    final updatedMeals = Map<MealType, List<Meal>>.from(state.meals)
      ..[event.mealType] = updatedMealsList;

    emit(state.copyWith(meals: updatedMeals));

    try {
      final updatedMeal = updatedMealsList.firstWhere((m) => m.id == targetMealId);
      final result = await repository.updateMealItem(updatedMeal);
      result.fold(
        (failure) => debugPrint('❌ Comment error: $failure'),
        (_) => debugPrint('✅ Comment saved'),
      );
    } catch (e) {
      add(LoadDiaryData(date: state.selectedDate));
    }
  }
}