import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/measurement.dart';

abstract class MeasurementsSupabaseDataSource {
  Future<List<Measurement>> getMeasurements({
    required MeasurementPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> saveMeasurement(Measurement measurement);
  Future<void> deleteMeasurement(String id);
}

class MeasurementsSupabaseDataSourceImpl implements MeasurementsSupabaseDataSource {
  final SupabaseClient client;

  MeasurementsSupabaseDataSourceImpl({required this.client});

  @override
  Future<List<Measurement>> getMeasurements({
    required MeasurementPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    // ✅ Получаем все замеры пользователя (фильтрация — в Dart)
    final response = await client
        .from('body_measurements')
        .select()
        .eq('user_id', userId)
        .order('measured_at', ascending: false);

    final list = response as List;
    final result = <Measurement>[];

    for (final json in list) {
      final measuredAt = DateTime.parse(json['measured_at'] as String);

      // ✅ Фильтруем по датам в Dart
      if (startDate != null && measuredAt.isBefore(startDate)) continue;
      if (endDate != null) {
        final end = endDate.add(const Duration(days: 1));
        if (measuredAt.isAtSameMomentAs(end) || measuredAt.isAfter(end)) continue;
      }

      result.add(Measurement(
        id: json['id'] as String,
        date: measuredAt,
        chestCm: _toDouble(json['chest_cm']),
        waistCm: _toDouble(json['waist_cm']),
        hipsCm: _toDouble(json['hips_cm']),
        weightKg: _toDouble(json['weight_kg']),
      ));
    }

    return result;
  }

  @override
  Future<void> saveMeasurement(Measurement measurement) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    await client.from('body_measurements').insert({
      'user_id': userId,
      'waist_cm': measurement.waistCm,
      'chest_cm': measurement.chestCm,
      'hips_cm': measurement.hipsCm,
      'weight_kg': measurement.weightKg,
      'measured_at': measurement.date.toIso8601String(),
    });
  }

  @override
  Future<void> deleteMeasurement(String id) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    await client
        .from('body_measurements')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}