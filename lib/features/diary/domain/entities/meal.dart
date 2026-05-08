import 'package:equatable/equatable.dart';
import 'meal_type.dart';

class Meal extends Equatable {
  final String id;
  final String name;
  final String weight;
  final int calories;
  final int protein;
  final int fats;
  final int carbs;
  final MealType mealType;
  final DateTime createdAt;
  final String? comment;

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
    this.comment,
  });

  // ✅ Убираем const из empty(), т.к. конструктор не const из-за DateTime.now()
  static Meal empty() {
    return Meal(  // ✅ Без const
      id: '',
      name: '',
      weight: '0г',
      calories: 0,
      protein: 0,
      fats: 0,
      carbs: 0,
      mealType: MealType.breakfast,
      createdAt: DateTime(2000),  // ✅ Const-compatible дата
    );
  }

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
    String? comment,
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
      comment: comment ?? this.comment,
    );
  }

  @override
  List<Object?> get props => [
        id, name, weight, calories, protein, fats, carbs,
        mealType, createdAt, comment,
      ];
}