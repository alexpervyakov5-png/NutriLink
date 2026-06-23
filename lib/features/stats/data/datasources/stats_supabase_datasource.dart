import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/stats.dart';

abstract class StatsSupabaseDataSource {
  Future<NutritionStats> getNutritionStats({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  Future<List<WeightTrendPoint>> getWeightTrend({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  Future<int> getStreakDays();
}

class StatsSupabaseDataSourceImpl implements StatsSupabaseDataSource {
  final SupabaseClient client;

  StatsSupabaseDataSourceImpl({required this.client});

  @override
  Future<NutritionStats> getNutritionStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userId = SupabaseConfig.currentUserId;
    debugPrint('📊 getNutritionStats: userId=$userId');
    
    if (userId == null) {
      debugPrint('❌ User not authenticated');
      throw ServerException('Пользователь не авторизован');
    }

    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      debugPrint('  🔄 Отправляю запрос в daily_summary...');

      // ✅ ДОБАВЛЕН ТАЙМАУТ 5 СЕКУНД НА ЗАПРОС
      final response = await client
          .from('daily_summary')
          .select('protein_actual, fat_actual, carbs_actual, calories_actual')
          .eq('user_id', userId)
          .gte('date', startDateStr)
          .lte('date', endDateStr)
          .timeout(const Duration(seconds: 5));

      final data = response as List;
      debugPrint('  📥 Запрос выполнен! Найдено записей: ${data.length}');

      if (data.isEmpty) {
        debugPrint('  ⚠️ Нет данных за период, возвращаю нули');
        return const NutritionStats(
          protein: 0, fats: 0, carbs: 0, calories: 0,
          proteinPercent: 0, fatsPercent: 0, carbsPercent: 0,
        );
      }

      int totalProtein = 0, totalFats = 0, totalCarbs = 0, totalCalories = 0;
      
      for (final row in data) {
        totalProtein += _toInt(row['protein_actual']);
        totalFats += _toInt(row['fat_actual']);
        totalCarbs += _toInt(row['carbs_actual']);
        totalCalories += _toInt(row['calories_actual']);
      }

      debugPrint('  ✅ Подсчет завершен: P=$totalProtein, F=$totalFats, C=$totalCarbs, K=$totalCalories');

      return NutritionStats.fromMacros(
        protein: totalProtein,
        fats: totalFats,
        carbs: totalCarbs,
        calories: totalCalories,
      );
    } on TimeoutException {
      debugPrint('❌ TIMEOUT: Запрос к daily_summary завис дольше 5 секунд!');
      throw ServerException('База данных не отвечает. Проверьте интернет или RLS политики.');
    } on PostgrestException catch (e) {
      debugPrint('❌ DB Error: ${e.message}');
      throw ServerException('Ошибка БД: ${e.message}');
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      throw ServerException('Неизвестная ошибка при загрузке питания');
    }
  }

  @override
  Future<List<WeightTrendPoint>> getWeightTrend({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    debugPrint('📈 getWeightTrend: userId=$userId');

    try {
      final response = await client
          .from('body_measurements')
          .select('measured_at, weight_kg')
          .eq('user_id', userId)
          .gte('measured_at', startDate.toIso8601String())
          .lte('measured_at', endDate.toIso8601String())
          .order('measured_at', ascending: true)
          .timeout(const Duration(seconds: 5));

      final data = response as List;
      debugPrint('  📥 Замеров веса найдено: ${data.length}');

      return data
          .where((json) => json['weight_kg'] != null)
          .map((json) => WeightTrendPoint(
                date: DateTime.parse(json['measured_at'] as String),
                weightKg: _toDouble(json['weight_kg']) ?? 0,
              ))
          .toList();
    } catch (e) {
      debugPrint('❌ Weight trend error: $e');
      return [];
    }
  }

  @override
  Future<int> getStreakDays() async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return 0;

    try {
      final response = await client
          .from('daily_summary')
          .select('calories_actual')
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(30)
          .timeout(const Duration(seconds: 3));

      final data = response as List;
      if (data.isEmpty) return 0;

      final goalsResponse = await client
          .from('user_goals')
          .select('calories_target')
          .eq('user_id', userId)
          .eq('is_active', true)
          .maybeSingle()
          .timeout(const Duration(seconds: 3));
      
      final targetCalories = _toInt(goalsResponse?['calories_target']) ?? 2500;
      
      int streak = 0;
      for (final row in data) {
        final actual = _toInt(row['calories_actual']) ?? 0;
        final ratio = targetCalories > 0 ? actual / targetCalories : 0;
        if (ratio >= 0.9 && ratio <= 1.1) streak++;
        else break;
      }
      return streak;
    } catch (e) {
      return 0;
    }
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

