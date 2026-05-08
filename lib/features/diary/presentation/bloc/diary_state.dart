import 'package:equatable/equatable.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/daily_goals.dart';
class DiaryState extends Equatable {
  final DailyGoals? goals;
  final Map<MealType, List<Meal>> meals;
  final Map<MealType, bool> expandedSections;
  final DateTime selectedDate;
  final bool isLoading;
  final String? error;

  const DiaryState({this.goals, required this.meals, required this.expandedSections, 
    required this.selectedDate, this.isLoading = false, this.error});

  factory DiaryState.initial() => DiaryState(
    meals: {MealType.breakfast: [], MealType.lunch: [], MealType.dinner: [], MealType.snack: []},
    expandedSections: {MealType.breakfast: true, MealType.lunch: true, MealType.dinner: false, MealType.snack: false},
    selectedDate: DateTime.now());

  DiaryState copyWith({DailyGoals? goals, Map<MealType, List<Meal>>? meals, 
    Map<MealType, bool>? expandedSections, DateTime? selectedDate, bool? isLoading, String? error}) {
    return DiaryState(
      goals: goals ?? this.goals, meals: meals ?? this.meals,
      expandedSections: expandedSections ?? this.expandedSections,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading, error: error);
  }

  @override
  List<Object?> get props => [goals, meals, expandedSections, selectedDate, isLoading, error];
}