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

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        autoRefreshToken: true,
      ),
      debug: false, // ✅ Поставьте true для отладки запросов
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  
  static String? get currentUserId => client.auth.currentUser?.id;
  
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  static Future<void> signOut() async => await client.auth.signOut();
}