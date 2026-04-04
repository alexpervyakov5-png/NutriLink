import '../../domain/entities/meal.dart';

class MealModel extends Meal {
  MealModel({required super.id, required super.name, required super.weight, required super.calories, 
    required super.protein, required super.fats, required super.carbs, required super.createdAt});

  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
    id: json['id'], name: json['name'], weight: '${json['weight_grams']} г',
    calories: json['calories'], protein: json['protein_grams'], fats: json['fat_grams'],
    carbs: json['carbs_grams'], createdAt: DateTime.parse(json['created_at']));

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'weight_grams': int.parse(weight.replaceAll(' г', '')),
    'calories': calories, 'protein_grams': protein, 'fat_grams': fats,
    'carbs_grams': carbs, 'created_at': createdAt.toIso8601String(),
  };
}

class DailyGoalsModel extends DailyGoals {
  const DailyGoalsModel({required super.proteinTarget, required super.fatsTarget, 
    required super.carbsTarget, required super.caloriesTarget, required super.proteinCurrent, 
    required super.fatsCurrent, required super.carbsCurrent, required super.caloriesCurrent});

  factory DailyGoalsModel.fromJson(Map<String, dynamic> json) => DailyGoalsModel(
    proteinTarget: json['protein_target'], fatsTarget: json['fat_target'],
    carbsTarget: json['carbs_target'], caloriesTarget: json['calories_target'],
    proteinCurrent: json['protein_current'], fatsCurrent: json['fat_current'],
    carbsCurrent: json['carbs_current'], caloriesCurrent: json['calories_current']);
}