import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/daily_goals.dart';

abstract class DiarySupabaseDataSource {
  Future<DailyGoals> getDailyGoals(DateTime date);
  Future<List<Meal>> getMealsByType(MealType type, DateTime date);
  Future<void> addMealItem(Meal meal, String? productId);
  Future<void> updateMealItem(Meal meal);
  Future<void> deleteMealItem(String mealId);
}

class DiarySupabaseDataSourceImpl implements DiarySupabaseDataSource {
  final SupabaseClient client;
  final Uuid _uuid = const Uuid();

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
        .select('''
          id,
          meal_type,
          eaten_at,
          comment,
          meal_items (
            id,
            amount_grams,
            product_id,
            product_name,
            calories,
            protein,
            fat,
            carbs
          )
        ''')
        .eq('user_id', userId)
        .eq('meal_type', _mapMealType(type))
        .order('eaten_at', ascending: false);

    final meals = mealsResponse as List;
    final result = <Meal>[];

    for (final json in meals) {
      final eatenAt = DateTime.parse(json['eaten_at'] as String);
      if (eatenAt.year != date.year || 
          eatenAt.month != date.month || 
          eatenAt.day != date.day) {
        continue;
      }

      final items = json['meal_items'] as List? ?? [];
      
      int totalWeight = 0;
      int totalCalories = 0;
      int totalProtein = 0;
      int totalFats = 0;
      int totalCarbs = 0;
      String? firstName;

      for (final item in items) {
        final amount = _toInt(item['amount_grams']) ?? 0;
        totalWeight += amount;

        totalCalories += _toInt(item['calories']) ?? 0;
        totalProtein += _toInt(item['protein']) ?? 0;
        totalFats += _toInt(item['fat']) ?? 0;
        totalCarbs += _toInt(item['carbs']) ?? 0;

        firstName ??= item['product_name'] as String?;
      }

      result.add(Meal(
        id: json['id'] as String,
        name: firstName ?? 'Блюдо',
        weight: '${totalWeight}г',
        calories: totalCalories,
        protein: totalProtein,
        fats: totalFats,
        carbs: totalCarbs,
        mealType: type,
        createdAt: eatenAt,
        comment: json['comment'] as String?,
      ));
    }

    return result;
  }

  @override
  Future<void> addMealItem(Meal meal, String? productId) async {
    debugPrint('🔍 DataSource: addMealItem START');
    debugPrint('  meal.comment: "${meal.comment}"');
    
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    final dateStr = meal.createdAt.toIso8601String().split('T')[0];
    final mealTypeStr = _mapMealType(meal.mealType);
    final itemId = _uuid.v4();

    try {
      final existingMeal = await client
          .from('meals')
          .select('id, comment')
          .eq('user_id', userId)
          .eq('date', dateStr)
          .eq('meal_type', mealTypeStr)
          .maybeSingle();

      String mealId;

      if (existingMeal == null) {
        debugPrint('📤 Создаём НОВЫЙ meal');
        mealId = _uuid.v4();
        
        final mealData = <String, dynamic>{
          'id': mealId,
          'user_id': userId,
          'meal_type': mealTypeStr,
          'date': dateStr,
          'eaten_at': meal.createdAt.toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        };

        if (meal.comment != null && meal.comment!.isNotEmpty) {
          mealData['comment'] = meal.comment;
          debugPrint('💬 Добавлен комментарий в INSERT: "${meal.comment}"');
        }

        await client.from('meals').insert(mealData);
        debugPrint('✅ Meal создан');
      } else {
        mealId = existingMeal['id'] as String;
        debugPrint('✅ Найден СУЩЕСТВУЮЩИЙ meal: $mealId');
        
        if (meal.comment != null && meal.comment!.isNotEmpty) {
          final existingComment = existingMeal['comment'] as String?;
          if (existingComment != meal.comment) {
            debugPrint('🔄 Обновляем комментарий: "${meal.comment}"');
            await client.from('meals').update({
              'comment': meal.comment,
            }).eq('id', mealId);
          }
        }
      }

      debugPrint('📤 Вставляем в meal_items...');
      await client.from('meal_items').insert({
        'id': itemId,
        'meal_id': mealId,
        'product_id': productId,
        'product_name': meal.name,
        'amount_grams': _parseWeight(meal.weight),
        'calories': meal.calories,
        'protein': meal.protein,
        'fat': meal.fats,
        'carbs': meal.carbs,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ DataSource: addMealItem УСПЕШНО');
      
    } catch (e, stack) {
      debugPrint('❌ DataSource: addMealItem ОШИБКА: $e');
      debugPrint('📋 Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<void> updateMealItem(Meal meal) async {
    debugPrint('🔍 DataSource: updateMealItem START');
    debugPrint('  meal.id: ${meal.id}');
    debugPrint('  meal.comment: "${meal.comment}"');
    
    try {
      final updateData = <String, dynamic>{};
      
      if (meal.comment != null) {
        updateData['comment'] = meal.comment;
        debugPrint('💬 Обновляем комментарий: "${meal.comment}"');
      }

      // Если данных для обновления нет, выходим, чтобы не вызывать пустой запрос к БД
      if (updateData.isEmpty) {
        debugPrint('⚠️ Нет полей для обновления, пропускаем запрос');
        return;
      }
      
      await client.from('meals').update(updateData).eq('id', meal.id);
      debugPrint('✅ DataSource: updateMealItem успешно');
      
    } catch (e, stack) {
      debugPrint('❌ DataSource: updateMealItem ошибка: $e');
      debugPrint(' Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<void> deleteMealItem(String mealId) async {
    debugPrint('🔍 DataSource: deleteMealItem id=$mealId');
    
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    try {
      await client.from('meal_items').delete().eq('meal_id', mealId);
      await client.from('meals').delete().eq('id', mealId).eq('user_id', userId);
      debugPrint('✅ DataSource: meal и items удалены');
    } catch (e, stack) {
      debugPrint('❌ DataSource: deleteMealItem ошибка: $e');
      debugPrint('📋 Stack: $stack');
      rethrow;
    }
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

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }
}