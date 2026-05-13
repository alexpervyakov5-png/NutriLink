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
      final response = await client
          .from('body_measurements')
          .select()
          .eq('user_id', userId)
          .order('measured_at', ascending: false);

      final allMeasurements = (response as List)
          .map((json) => _parseMeasurement(json))
          .toList();

      debugPrint('✅ DataSource: Получено ${allMeasurements.length} записей из БД');

      if (startDate != null || endDate != null) {
        final filtered = allMeasurements.where((m) {
          if (startDate != null && m.measuredAt.isBefore(startDate)) return false;
          if (endDate != null && m.measuredAt.isAfter(endDate)) return false;
          return true;
        }).toList();
        
        debugPrint('✅ DataSource: После фильтрации осталось ${filtered.length} записей');
        return filtered;
      }

      return allMeasurements;
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
    debugPrint('  measuredAt: ${measurement.measuredAt}');
    debugPrint('  chestCm: ${measurement.chestCm}');
    debugPrint('  waistCm: ${measurement.waistCm}');
    debugPrint('  hipsCm: ${measurement.hipsCm}');
    
    try {
      if (measurement.userId.isEmpty) {
        throw Exception('userId is empty!');
      }
      
      final data = {
        'id': measurement.id,
        'user_id': measurement.userId,
        'measured_at': measurement.measuredAt.toIso8601String(),
        'chest_cm': measurement.chestCm,
        'waist_cm': measurement.waistCm,
        'hips_cm': measurement.hipsCm,
      };
      
      debugPrint('📤 DataSource: Отправляем в Supabase: $data');
      
      final response = await client.from('body_measurements').insert(data);
      
      debugPrint('✅ DataSource: Ответ от Supabase: $response');
      
      if (response is Map && response.containsKey('error')) {
        throw Exception('Supabase error: ${response['error']}');
      }
    } catch (e, stack) {
      debugPrint('❌ DataSource: saveMeasurement ошибка: $e');
      debugPrint('📋 Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<void> updateMeasurement(Measurement measurement) async {
    debugPrint('🔍 DataSource: updateMeasurement');
    debugPrint('  id: ${measurement.id}');
    debugPrint('  measuredAt: ${measurement.measuredAt}');
    debugPrint('  chestCm: ${measurement.chestCm}');
    debugPrint('  waistCm: ${measurement.waistCm}');
    debugPrint('  hipsCm: ${measurement.hipsCm}');
    
    try {
      await client.from('body_measurements').update({
        'measured_at': measurement.measuredAt.toIso8601String(),
        'chest_cm': measurement.chestCm,
        'waist_cm': measurement.waistCm,
        'hips_cm': measurement.hipsCm,
      }).eq('id', measurement.id);
      
      debugPrint('✅ DataSource: updateMeasurement успешно');
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