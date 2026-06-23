import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/measurement.dart';

abstract class MeasurementsSupabaseDataSource {
  Future<List<Measurement>> getMeasurements({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> saveMeasurement(Measurement measurement);
  Future<void> updateMeasurement(Measurement measurement);
  Future<void> deleteMeasurement(String id);
}

class MeasurementsSupabaseDataSourceImpl implements MeasurementsSupabaseDataSource {
  final SupabaseClient client;

  MeasurementsSupabaseDataSourceImpl({required this.client});

  @override
  Future<List<Measurement>> getMeasurements({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    debugPrint('🔍 DataSource: getMeasurements userId=$userId');
    
    try {
      if (userId.isEmpty) {
        throw Exception('userId is empty - cannot fetch measurements');
      }

      final response = await client
          .from('body_measurements')
          .select()
          .eq('user_id', userId)
          .order('measured_at', ascending: false);

      final List<dynamic> rawData;
      if (response is List) {
        rawData = response;
      } else if (response == null) {
        rawData = [];
      } else {
        rawData = [response];
      }

      final allMeasurements = rawData
          .map((json) => _parseMeasurement(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ DataSource: Получено ${allMeasurements.length} записей из БД');

      if (startDate != null || endDate != null) {
        final filtered = allMeasurements.where((m) {
          if (startDate != null && m.measuredAt.isBefore(startDate)) return false;
          if (endDate != null) {
            final mDate = DateTime(m.measuredAt.year, m.measuredAt.month, m.measuredAt.day);
            final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
            if (mDate.isAfter(endDateOnly)) return false;
          }
          return true;
        }).toList();
        
        debugPrint('✅ DataSource: После фильтрации осталось ${filtered.length} записей');
        return filtered;
      }

      return allMeasurements;
    } on PostgrestException catch (e) {
      debugPrint('❌ DataSource: PostgrestException: ${e.message}');
      throw Exception('Ошибка базы данных: ${e.message}');
    } on AuthException catch (e) {
      debugPrint('❌ DataSource: AuthException: ${e.message}');
      throw Exception('Ошибка авторизации: ${e.message}');
    } catch (e, stack) {
      debugPrint('❌ DataSource: getMeasurements ошибка: $e');
      debugPrint('📋 Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<void> saveMeasurement(Measurement measurement) async {
    debugPrint('🔍 DataSource: saveMeasurement');
    debugPrint('  id: ${measurement.id}');
    debugPrint('  userId: ${measurement.userId}');
    debugPrint('  weightKg: ${measurement.weightKg}');
    
    try {
      if (measurement.userId.isEmpty) {
        throw Exception('userId is empty!');
      }
      
      final data = <String, dynamic>{
        'id': measurement.id,
        'user_id': measurement.userId,
        'measured_at': measurement.measuredAt.toIso8601String(),
        'weight_kg': measurement.weightKg,
        'chest_cm': measurement.chestCm,
        'waist_cm': measurement.waistCm,
        'hips_cm': measurement.hipsCm,
      };
      
      data.removeWhere((key, value) => value == null);
      
      debugPrint('📤 DataSource: Отправляем в Supabase: $data');
      
      final response = await client.from('body_measurements').insert(data);
      
      debugPrint('✅ DataSource: Ответ от Supabase: $response');
      
      if (response is Map && response.containsKey('error')) {
        throw Exception('Supabase error: ${response['error']}');
      }
    } on PostgrestException catch (e) {
      debugPrint('❌ DataSource: PostgrestException при сохранении: ${e.message}');
      throw Exception('Не удалось сохранить: ${e.message}');
    } catch (e, stack) {
      debugPrint('❌ DataSource: saveMeasurement ошибка: $e');
      debugPrint('📋 Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<void> updateMeasurement(Measurement measurement) async {
    debugPrint('🔍 DataSource: updateMeasurement id=${measurement.id}');
    
    try {
      final data = <String, dynamic>{
        'measured_at': measurement.measuredAt.toIso8601String(),
        'weight_kg': measurement.weightKg,
        'chest_cm': measurement.chestCm,
        'waist_cm': measurement.waistCm,
        'hips_cm': measurement.hipsCm,
      };
      
      data.removeWhere((key, value) => value == null);
      
      if (data.isEmpty) {
        debugPrint('⚠️ Нет данных для обновления');
        return;
      }
      
      await client.from('body_measurements').update(data).eq('id', measurement.id);
      debugPrint('✅ DataSource: updateMeasurement успешно');
    } on PostgrestException catch (e) {
      debugPrint('❌ DataSource: PostgrestException при обновлении: ${e.message}');
      throw Exception('Не удалось обновить: ${e.message}');
    } catch (e, stack) {
      debugPrint('❌ DataSource: updateMeasurement ошибка: $e');
      debugPrint('📋 Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<void> deleteMeasurement(String id) async {
    debugPrint('🔍 DataSource: deleteMeasurement id=$id');
    
    try {
      await client.from('body_measurements').delete().eq('id', id);
      debugPrint('✅ DataSource: deleteMeasurement успешно');
    } on PostgrestException catch (e) {
      debugPrint('❌ DataSource: PostgrestException при удалении: ${e.message}');
      throw Exception('Не удалось удалить: ${e.message}');
    } catch (e, stack) {
      debugPrint('❌ DataSource: deleteMeasurement ошибка: $e');
      debugPrint('📋 Stack: $stack');
      rethrow;
    }
  }

  Measurement _parseMeasurement(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      measuredAt: DateTime.parse(json['measured_at'] as String),
      weightKg: _toDouble(json['weight_kg']),
      chestCm: _toDouble(json['chest_cm']),
      waistCm: _toDouble(json['waist_cm']),
      hipsCm: _toDouble(json['hips_cm']),
    );
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}