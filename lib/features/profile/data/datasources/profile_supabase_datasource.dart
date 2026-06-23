import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/profile.dart';

abstract class ProfileSupabaseDataSource {
  Future<Profile> getProfile();
  Future<void> updateProfile(Profile profile);
}

class ProfileSupabaseDataSourceImpl implements ProfileSupabaseDataSource {
  final SupabaseClient client;

  ProfileSupabaseDataSourceImpl({required this.client});

  @override
  Future<Profile> getProfile() async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    final response = await client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (kDebugMode) {
      if (response == null) {
        debugPrint('📭 Профиль не найден в БД (новая регистрация)');
      } else {
        debugPrint('✅ Профиль найден:');
        response.forEach((key, value) => debugPrint('   $key: $value'));
      }
    }

    if (response == null) {
      return Profile(
        id: userId,
        firstName: '',
        lastName: '',
        goal: GoalType.maintenance,
        heightCm: null,
        birthDate: null,
        gender: null,
      );
    }

    GoalType parseGoal(String? goalStr) {
      if (goalStr == null) return GoalType.maintenance;
      try {
        return GoalType.values.firstWhere(
          (e) => e.toString().split('.').last == goalStr,
          orElse: () => GoalType.maintenance,
        );
      } catch (_) {
        return GoalType.maintenance;
      }
    }

    return Profile(
      id: response['id'],
      firstName: _parseFirstName(response['username']),
      lastName: _parseLastName(response['username']),
      birthDate: response['date_of_birth'] != null 
          ? DateTime.parse(response['date_of_birth']) 
          : null,
      heightCm: response['height_cm']?.toInt(),
      gender: response['gender'],
      goal: parseGoal(response['goal']),
    );
  }

  String _parseFirstName(dynamic username) {
    if (username == null) return '';
    final name = username.toString().trim();
    return name.isEmpty ? '' : name.split(' ').first;
  }

  String _parseLastName(dynamic username) {
    if (username == null) return '';
    final name = username.toString().trim();
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    return parts.length > 1 ? parts.skip(1).join(' ') : '';
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw ServerException('Пользователь не авторизован');

    if (kDebugMode) {
      debugPrint('💾 Сохранение профиля:');
      debugPrint('   userId: $userId');
      debugPrint('   username: ${profile.firstName} ${profile.lastName}');
      debugPrint('   goal: ${profile.goal}');
      debugPrint('   gender: ${profile.gender}');
    }

    final username = '${profile.firstName} ${profile.lastName}'.trim();
    final userEmail = client.auth.currentUser?.email ?? '';

    try {
      await client.from('users').upsert({
        'id': userId,
        'username': username.isNotEmpty ? username : null,
        'email': userEmail,
        'height_cm': profile.heightCm,
        'gender': profile.gender,
        'goal': profile.goal.toString().split('.').last,
        'date_of_birth': profile.birthDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      if (kDebugMode) debugPrint('✅ Профиль успешно сохранён!');
      
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PostgrestException: ${e.message}');
        debugPrint('🔎 details: ${e.details}');
        debugPrint('💡 hint: ${e.hint}');
      }
      throw ServerException('Ошибка сохранения: ${e.message}');
      
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Исключение: $e');
        debugPrint('📋 Stack: $stack');
      }
      throw ServerException('Ошибка: ${e.toString()}');
    }
  }
}