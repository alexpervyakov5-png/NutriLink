import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/daily_goals.dart';

abstract class DiarySupabaseDataSource {
  Future<DailyGoals> getDailyGoals(DateTime date);
  Future<List<Meal>> getMealsByType(MealType type, DateTime date);
  
  // ✅ Методы для сохранения
  Future<void> addMeal(Meal meal);
  Future<void> updateMeal(Meal meal);
  Future<void> deleteMeal(String mealId);
}

class DiarySupabaseDataSourceImpl implements DiarySupabaseDataSource {
  final SupabaseClient client;

  DiarySupabaseDataSourceImpl({required this.client});

  @override
  Future<DailyGoals> getDailyGoals(DateTime date) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    final dateStr = date.toIso8601String().split('T')[0];

    final summaryResponse = await client
        .from('daily_summary')
        .select()
        .eq('user_id', userId)
        .eq('date', dateStr)
        .maybeSingle();

    final goalsResponse = await client
        .from('user_goals')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .maybeSingle();

    return DailyGoals(
      proteinTarget: _toInt(goalsResponse?['protein_target']) ?? 100,
      fatsTarget: _toInt(goalsResponse?['fat_target']) ?? 65,
      carbsTarget: _toInt(goalsResponse?['carbs_target']) ?? 285,
      caloriesTarget: _toInt(goalsResponse?['calories_target']) ?? 2500,
      proteinCurrent: _toInt(summaryResponse?['protein_actual']) ?? 0,
      fatsCurrent: _toInt(summaryResponse?['fat_actual']) ?? 0,
      carbsCurrent: _toInt(summaryResponse?['carbs_actual']) ?? 0,
      caloriesCurrent: _toInt(summaryResponse?['calories_actual']) ?? 0,
    );
  }

  @override
  Future<List<Meal>> getMealsByType(MealType type, DateTime date) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    final mealsResponse = await client
        .from('meals')
        .select()
        .eq('user_id', userId)
        .eq('meal_type', _mapMealType(type))
        .order('eaten_at', ascending: false);

    final meals = mealsResponse as List;
    final result = <Meal>[];

    for (final json in meals) {
      final eatenAt = DateTime.parse(json['eaten_at'] as String);
      if (!_isSameDay(eatenAt, date)) continue;

      result.add(Meal(
        id: json['id'] as String,
        name: json['name'] as String,
        weight: '${json['weight']}г',
        calories: _toInt(json['calories']) ?? 0,
        protein: _toInt(json['protein']) ?? 0,
        fats: _toInt(json['fats']) ?? 0,
        carbs: _toInt(json['carbs']) ?? 0,
        mealType: type,
        createdAt: eatenAt,
        comment: json['comment'] as String?,
      ));
    }

    return result;
  }

  // ✅ ДОБАВЛЕНИЕ блюда в Supabase
  @override
  Future<void> addMeal(Meal meal) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    await client.from('meals').insert({
      'id': meal.id,
      'user_id': userId,
      'meal_type': _mapMealType(meal.mealType),
      'eaten_at': meal.createdAt.toIso8601String(),
      'name': meal.name,
      'weight': _parseWeight(meal.weight),
      'calories': meal.calories,
      'protein': meal.protein,
      'fats': meal.fats,
      'carbs': meal.carbs,
      'comment': meal.comment,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ✅ ОБНОВЛЕНИЕ блюда в Supabase
  @override
  Future<void> updateMeal(Meal meal) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    await client.from('meals').update({
      'name': meal.name,
      'weight': _parseWeight(meal.weight),
      'calories': meal.calories,
      'protein': meal.protein,
      'fats': meal.fats,
      'carbs': meal.carbs,
      'comment': meal.comment,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', meal.id).eq('user_id', userId);
  }

  // ✅ УДАЛЕНИЕ блюда из Supabase
  @override
  Future<void> deleteMeal(String mealId) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    await client.from('meals').delete().eq('id', mealId).eq('user_id', userId);
  }

  String _mapMealType(MealType type) {
    switch (type) {
      case MealType.breakfast: return 'breakfast';
      case MealType.lunch: return 'lunch';
      case MealType.dinner: return 'dinner';
      case MealType.snack: return 'snack';
    }
  }

  int _parseWeight(String weightStr) {
    return int.tryParse(weightStr.replaceAll('г', '').trim()) ?? 0;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }
}