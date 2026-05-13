import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // ✅ Ваши реальные данные как значения по умолчанию
  static String get url => const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://exbzeuakjfulhzasxiyr.supabase.co',
  );

  static String get anonKey => const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4YnpldWFramZ1bGh6YXN4aXlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1NDE3MjQsImV4cCI6MjA5MzExNzcyNH0.PgY8qpE_K40JRrrpK9sijqCFaDz2ktdbclvEJ0k6diY',
  );

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce, // ✅ Используем современный PKCE flow
        autoRefreshToken: true,
      ),
      debug: true, // ✅ Включите для отладки запросов к Supabase
    );
    
    // ✅ Ждём восстановления сессии
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isInitialized = true;
    print('✅ Supabase initialized');
    print('🔍 Current user after init: ${client.auth.currentUser?.id ?? "NULL"}');
  }

  static SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('SupabaseConfig.initialize() must be called first!');
    }
    return Supabase.instance.client;
  }
  
  // ✅ Надёжное получение userId с проверкой
  static String? get currentUserId {
    if (!_isInitialized) return null;
    
    final user = client.auth.currentUser;
    // ✅ Логируем для отладки
    if (user == null) {
      print('⚠️ currentUserId: user is null (not authenticated)');
    } else {
      print('✅ currentUserId: ${user.id}');
    }
    return user?.id;
  }
  
  // ✅ Проверка: авторизован ли пользователь
  static bool get isAuthorized => currentUserId != null;
  
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  static Future<void> signOut() async => await client.auth.signOut();
}