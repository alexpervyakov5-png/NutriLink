import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth_user.dart';

abstract class AuthSupabaseDataSource {
  Future<AuthUser> signInWithEmail(String email, String password);
  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required UserRole role,
  });
  Future<void> signOut();
  Future<AuthUser?> getCurrentUser();
}

class AuthSupabaseDataSourceImpl implements AuthSupabaseDataSource {
  final SupabaseClient client;

  AuthSupabaseDataSourceImpl({required this.client});

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    if (kDebugMode) debugPrint('🔍 Вход: $email');
    
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw ServerException('Пользователь не найден');

      if (kDebugMode) debugPrint('✅ Вход успешен: ${user.id}');

      final userData = await client
          .from('users')
          .select('username, role')
          .eq('id', user.id)
          .maybeSingle();

      return AuthUser(
        id: user.id,
        email: user.email ?? '',
        username: userData?['username'] as String?,
        role: _parseRole(userData?['role'] as String?),
        createdAt: user.createdAt != null ? DateTime.parse(user.createdAt!) : null,
      );
    } on AuthException catch (e) {
      if (kDebugMode) debugPrint('❌ AuthException: ${e.message}');
      throw ServerException(e.message);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Ошибка: $e');
        debugPrint('📋 Stack: $stack');
      }
      throw ServerException('Ошибка входа: ${e.toString()}');
    }
  }

  @override
  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required UserRole role,
  }) async {
    if (kDebugMode) {
      debugPrint('🔍 Регистрация: $email');
      debugPrint('👤 $username, роль: $role');
    }
    
    try {
      // ✅ data: — именованный параметр!
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {  // ✅ КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ: добавлено data:
          'username': username,
          'role': role == UserRole.trainer ? 'trainer' : 'client',
        },
      );

      final user = response.user;
      if (user == null) {
        if (kDebugMode) debugPrint('❌ Пользователь не создан');
        throw ServerException('Ошибка регистрации');
      }

      if (kDebugMode) {
        debugPrint('📦 user.id: ${user.id}');
        debugPrint('📧 confirmed: ${user.emailConfirmedAt}');
      }

      // Ждём триггер
      await Future.delayed(const Duration(milliseconds: 500));

      // Проверка public.users
      final check = await client
          .from('users')
          .select('id, username, role')
          .eq('id', user.id)
          .maybeSingle();
      
      if (kDebugMode) {
        debugPrint('🔎 public.users: ${check != null ? "✅" : "❌"}');
      }

      // Цели для тренера
      if (role == UserRole.trainer) {
        await client.from('user_goals').insert({
          'user_id': user.id,
          'calories_target': 2500,
          'protein_target': 150.0,
          'fat_target': 80.0,
          'carbs_target': 280.0,
          'is_active': true,
        });
      }

      return AuthUser(
        id: user.id,
        email: user.email ?? '',
        username: username,
        role: role,
        createdAt: user.createdAt != null ? DateTime.parse(user.createdAt!) : null,
      );
    } on AuthException catch (e) {
      if (kDebugMode) debugPrint('❌ AuthException: ${e.message}');
      throw ServerException(e.message);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Ошибка: $e');
        debugPrint('📋 Stack: $stack');
      }
      throw ServerException('Ошибка регистрации: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    if (kDebugMode) debugPrint('🔐 Выход');
    try {
      await client.auth.signOut();
    } catch (e) {
      throw ServerException('Ошибка выхода: ${e.toString()}');
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    try {
      final userData = await client
          .from('users')
          .select('username, role')
          .eq('id', user.id)
          .maybeSingle();

      return AuthUser(
        id: user.id,
        email: user.email ?? '',
        username: userData?['username'] as String?,
        role: _parseRole(userData?['role'] as String?),
        createdAt: user.createdAt != null ? DateTime.parse(user.createdAt!) : null,
      );
    } catch (_) {
      return AuthUser(
        id: user.id,
        email: user.email ?? '',
        username: null,
        role: UserRole.client,
        createdAt: user.createdAt != null ? DateTime.parse(user.createdAt!) : null,
      );
    }
  }

  UserRole _parseRole(String? role) {
    if (role == 'trainer') return UserRole.trainer;
    return UserRole.client;
  }
}