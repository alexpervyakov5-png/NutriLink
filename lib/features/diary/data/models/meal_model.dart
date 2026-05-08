import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_type.dart';

class MealModel extends Meal {
  const MealModel({
    required super.id,
    required super.name,
    required super.weight,
    required super.calories,
    required super.protein,
    required super.fats,
    required super.carbs,
    required super.mealType,
    required super.createdAt,
    super.comment,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as String,
      name: json['name'] as String,
      weight: '${json['weight']}г',  // ✅ Форматируем как "100г"
      calories: json['calories'] as int,
      protein: (json['protein'] as num).round(),
      fats: (json['fats'] as num).round(),
      carbs: (json['carbs'] as num).round(),
      mealType: _parseMealType(json['meal_type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight.replaceAll('г', ''),  // ✅ Храним число в БД
      'calories': calories,
      'protein': protein,
      'fats': fats,
      'carbs': carbs,
      'meal_type': mealType.name,
      'created_at': createdAt.toIso8601String(),
      'comment': comment,
    };
  }

  static MealType _parseMealType(String type) {
    switch (type) {
      case 'breakfast': return MealType.breakfast;
      case 'lunch': return MealType.lunch;
      case 'dinner': return MealType.dinner;
      case 'snack': return MealType.snack;
      default: return MealType.breakfast;
    }
  }
}