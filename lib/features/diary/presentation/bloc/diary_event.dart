import 'package:equatable/equatable.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_type.dart';

abstract class DiaryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Загрузить данные дневника за дату
class LoadDiaryData extends DiaryEvent {
  final DateTime date;
  LoadDiaryData({required this.date});
  
  @override
  List<Object?> get props => [date];
}

/// Переключить видимость раздела приёма пищи
class ToggleMealSection extends DiaryEvent {
  final MealType mealType;
  ToggleMealSection({required this.mealType});
  
  @override
  List<Object?> get props => [mealType];
}

/// ✅ НОВОЕ: Добавить продукт в приём пищи
class AddMealItem extends DiaryEvent {
  final MealType mealType;
  final String productId;
  final String productName;
  final String weight;          // ✅ String как в Meal
  final int calories;
  final int protein;            // ✅ int как в Meal (округляем в BLoC)
  final int fats;
  final int carbs;

  AddMealItem({
    required this.mealType,
    required this.productId,
    required this.productName,
    required this.weight,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
  });

  @override
  List<Object?> get props => [
        mealType,
        productId,
        productName,
        weight,
        calories,
        protein,
        fats,
        carbs,
      ];
}

/// ✅ НОВОЕ: Обновить существующий продукт в приёме пищи
class UpdateMealItem extends DiaryEvent {
  final String mealId;
  final MealType mealType;
  final String weight;
  final int calories;
  final int protein;
  final int fats;
  final int carbs;

  UpdateMealItem({
    required this.mealId,
    required this.mealType,
    required this.weight,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
  });

  @override
  List<Object?> get props => [
        mealId,
        mealType,
        weight,
        calories,
        protein,
        fats,
        carbs,
      ];
}

/// ✅ НОВОЕ: Удалить продукт из приёма пищи
class RemoveMealItem extends DiaryEvent {
  final String mealId;
  final MealType mealType;

  RemoveMealItem({
    required this.mealId,
    required this.mealType,
  });

  @override
  List<Object?> get props => [mealId, mealType];
}

/// ✅ НОВОЕ: Добавить комментарий к приёму пищи
class AddComment extends DiaryEvent {
  final MealType mealType;
  final String text;

  AddComment({
    required this.mealType,
    required this.text,
  });

  @override
  List<Object?> get props => [mealType, text];
}