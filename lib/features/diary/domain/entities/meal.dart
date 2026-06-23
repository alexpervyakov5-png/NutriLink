import 'package:equatable/equatable.dart';
import 'meal_type.dart';

class Meal extends Equatable {
  final String id;
  final String name;
  final String weight;
  final int calories, protein, fats, carbs;
  final MealType mealType;
  final DateTime createdAt;
  final String? comment; // ✅ Должно быть здесь

  const Meal({
    required this.id,
    required this.name,
    required this.weight,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.mealType,
    required this.createdAt,
    this.comment, // ✅
  });

  Meal copyWith({
    String? id,
    String? name,
    String? weight,
    int? calories,
    int? protein,
    int? fats,
    int? carbs,
    MealType? mealType,
    DateTime? createdAt,
    String? comment, // ✅
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fats: fats ?? this.fats,
      carbs: carbs ?? this.carbs,
      mealType: mealType ?? this.mealType,
      createdAt: createdAt ?? this.createdAt,
      comment: comment ?? this.comment, // ✅
    );
  }

  @override
  List<Object?> get props => [id, name, weight, calories, protein, fats, carbs, mealType, createdAt, comment];
}