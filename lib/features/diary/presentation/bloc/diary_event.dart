import 'package:equatable/equatable.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_type.dart';

abstract class DiaryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDiaryData extends DiaryEvent {
  final DateTime date;
  LoadDiaryData({required this.date});
  @override
  List<Object?> get props => [date];
}

class ToggleMealSection extends DiaryEvent {
  final MealType mealType;
  ToggleMealSection({required this.mealType});
  @override
  List<Object?> get props => [mealType];
}

class AddMealItem extends DiaryEvent {
  final MealType mealType;
  final String productId;
  final String productName;
  final String weight;
  final int calories;
  final int protein;
  final int fats;
  final int carbs;
  final String? comment;

  AddMealItem({
    required this.mealType,
    required this.productId,
    required this.productName,
    required this.weight,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    this.comment,
  });

  @override
  List<Object?> get props => [
        mealType, productId, productName, weight,
        calories, protein, fats, carbs, comment
      ];
}

class UpdateMealItem extends DiaryEvent {
  final String mealId;
  final MealType mealType;
  final String weight;
  final int calories;
  final int protein;
  final int fats;
  final int carbs;
  final String? comment; // ✅ Добавлено

  UpdateMealItem({
    required this.mealId,
    required this.mealType,
    required this.weight,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    this.comment,
  });

  @override
  List<Object?> get props => [mealId, mealType, weight, calories, protein, fats, carbs, comment];
}

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

class AddComment extends DiaryEvent {
  final MealType mealType;
  final String? mealId; // ✅ ID блюда (если есть)
  final String? text;   // ✅ Текст комментария (null = удалить)

  AddComment({
    required this.mealType,
    this.mealId,
    required this.text,
  });

  @override
  List<Object?> get props => [mealType, mealId, text];
}