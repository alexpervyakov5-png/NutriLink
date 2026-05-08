import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart'; // ✅ Для debugPrint
// ✅ ИСПРАВЛЕНИЕ: скрываем конфликтующий AuthState, но оставляем остальные классы
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// ✅ Core
import 'core/utils/constants.dart';
import 'core/config/supabase_config.dart';

// ✅ Navigation
import 'bloc/navigation_bloc.dart';
import 'bloc/navigation_event.dart';
import 'bloc/navigation_state.dart';

// ✅ Auth
import 'features/auth/data/datasources/auth_supabase_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart'; // ✅ Ваш AuthState
import 'features/auth/presentation/pages/login_screen.dart';

// ✅ Profile
import 'features/profile/data/datasources/profile_supabase_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/get_profile.dart';
import 'features/profile/domain/usecases/update_profile.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';
import 'features/profile/presentation/pages/home_screen.dart';

// ✅ Diary
import 'features/diary/data/datasources/diary_supabase_datasource.dart';
import 'features/diary/data/repositories/diary_repository_impl.dart';
import 'features/diary/presentation/bloc/diary_bloc.dart';
import 'features/diary/presentation/bloc/diary_event.dart';
import 'features/diary/presentation/pages/diary_screen.dart';

// ✅ Measurements
import 'features/measurements/data/datasources/measurements_supabase_datasource.dart';
import 'features/measurements/data/repositories/measurements_repository_impl.dart';
import 'features/measurements/domain/usecases/get_measurements.dart';
import 'features/measurements/domain/usecases/save_measurement.dart';
import 'features/measurements/domain/entities/measurement.dart';
import 'features/measurements/presentation/bloc/measurements_bloc.dart';
import 'features/measurements/presentation/bloc/measurements_event.dart';
import 'features/measurements/presentation/pages/measurements_screen.dart';

// ✅ Stats
import 'features/stats/data/datasources/stats_mock_datasource.dart';
import 'features/stats/data/repositories/stats_repository_impl.dart';
import 'features/stats/domain/usecases/get_nutrition_stats.dart';
import 'features/stats/presentation/bloc/stats_bloc.dart';
import 'features/stats/presentation/bloc/stats_event.dart';
import 'features/stats/presentation/pages/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔍 Тест подключения к Supabase
  try {
    await SupabaseConfig.initialize();
    final test = await SupabaseConfig.client
        .from('products')
        .select('id')
        .limit(1);
    // ✅ Используем debugPrint из flutter/foundation.dart
    debugPrint('✅ Supabase подключён! Продуктов в БД: ${test.isNotEmpty ? 'есть' : 'нет'}');
  } catch (e) {
    debugPrint('❌ Ошибка подключения к Supabase: $e');
  }
  
  runApp(const NutriLinkApp());
}

class NutriLinkApp extends StatelessWidget {
  const NutriLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = SupabaseConfig.client;

    // 🔌 Auth Data Source & Repository
    final authDs = AuthSupabaseDataSourceImpl(client: supabaseClient);
    final authRepo = AuthRepositoryImpl(dataSource: authDs);

    // 🔌 Profile Data Source & Repository
    final profileDs = ProfileSupabaseDataSourceImpl(client: supabaseClient);
    final profileRepo = ProfileRepositoryImpl(supabaseDataSource: profileDs);

    // 🔌 Diary Data Source & Repository
    final diaryDs = DiarySupabaseDataSourceImpl(client: supabaseClient);
    final diaryRepo = DiaryRepositoryImpl(dataSource: diaryDs);

    // 🔌 Measurements Data Source & Repository
    final measurementsDs = MeasurementsSupabaseDataSourceImpl(client: supabaseClient);
    final measurementsRepo = MeasurementsRepositoryImpl(supabaseDataSource: measurementsDs);

    // 🔌 Stats (пока mock)
    final statsDs = StatsMockDataSourceImpl();
    final statsRepo = StatsRepositoryImpl(mockDataSource: statsDs);

    return MultiBlocProvider(
      providers: [
        // 🧭 Navigation
        BlocProvider(create: (_) => NavigationBloc()),
        
        // 🔐 Auth
        BlocProvider(
          create: (_) => AuthBloc(repository: authRepo)..add(AuthCheckRequested()),
        ),
        
        // 👤 Profile
        BlocProvider(
          create: (_) => ProfileBloc(
            getProfile: GetProfile(profileRepo),
            updateProfile: UpdateProfile(profileRepo),
          )..add(LoadProfile()),
        ),
        
        // 📓 Diary
        BlocProvider(
          create: (_) => DiaryBloc(repository: diaryRepo)..add(LoadDiaryData(date: DateTime.now())),
        ),
        
        // 📏 Measurements
        BlocProvider(
          create: (_) => MeasurementsBloc(
            getMeasurements: GetMeasurements(measurementsRepo),
            saveMeasurement: SaveMeasurement(measurementsRepo),
          )..add(LoadMeasurements(period: MeasurementPeriod.day)),
        ),
        
        // 📊 Stats
        BlocProvider(
          create: (_) => StatsBloc(
            getNutritionStats: GetNutritionStats(statsRepo),
          )..add(LoadStats(period: MeasurementPeriod.day)),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        
        // 🎨 Тема
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.textPrimary),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.backgroundSecondary,
            selectedItemColor: AppColors.accentLight,
            unselectedItemColor: Colors.grey,
          ),
        ),
        
        // 🔐 Auth Wrapper
        home: BlocBuilder<AuthBloc, AuthState>( // ✅ Теперь использует ваш AuthState
          builder: (context, state) {
            if (state is AuthInitial || state is AuthLoading) {
              return const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.accent),
                      SizedBox(height: 16),
                      Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: AppColors.accentLight,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            if (state is AuthAuthenticated) {
              return const MainScreen();
            }
            
            if (state is AuthUnauthenticated || state is AuthError) {
              return const LoginScreen();
            }
            
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

// 🏠 Main Screen
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              '${AppStrings.assetIcons}nutrilink.png',
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: AppColors.accentLight),
            ),
            const SizedBox(width: 8),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.accentLight,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
      body: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _buildScreen(state.index),
          );
        },
      ),
      bottomNavigationBar: const _BottomNavigation(),
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0: return const HomeScreen(key: ValueKey('home'));
      case 1: return const DiaryScreen(key: ValueKey('diary'));
      case 2: return const MeasurementsScreen(key: ValueKey('measurements'));
      case 3: return const StatsScreen(key: ValueKey('stats'));
      default: return const HomeScreen(key: ValueKey('home'));
    }
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.textPrimary),
            title: const Text('Профиль', style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              context.read<NavigationBloc>().add(TabTapped(0));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.textPrimary),
            title: const Text('Настройки', style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              // TODO: Открыть настройки
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Выйти', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// 🧭 Bottom Navigation
class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return BottomNavigationBar(
          currentIndex: state.index,
          onTap: (index) => context.read<NavigationBloc>().add(TabTapped(index)),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.backgroundSecondary,
          selectedItemColor: AppColors.accentLight,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: _navIcon('home.png', state.index == 0),
              activeIcon: _navIcon('home.png', true),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: _navIcon('book.png', state.index == 1),
              activeIcon: _navIcon('book.png', true),
              label: 'Дневник',
            ),
            BottomNavigationBarItem(
              icon: _navIcon('measurements.png', state.index == 2),
              activeIcon: _navIcon('measurements.png', true),
              label: 'Замеры',
            ),
            BottomNavigationBarItem(
              icon: _navIcon('stats.png', state.index == 3),
              activeIcon: _navIcon('stats.png', true),
              label: 'Статистика',
            ),
          ],
        );
      },
    );
  }

  Widget _navIcon(String name, bool selected) {
    return Image.asset(
      '${AppStrings.assetIcons}$name',
      width: 24,
      height: 24,
      color: selected ? AppColors.accentLight : Colors.grey,
      errorBuilder: (_, __, ___) => Icon(
        _getFallbackIcon(name),
        color: selected ? AppColors.accentLight : Colors.grey,
        size: 24,
      ),
    );
  }

  IconData _getFallbackIcon(String name) {
    switch (name) {
      case 'home.png': return Icons.home;
      case 'book.png': return Icons.book;
      case 'measurements.png': return Icons.straighten;
      case 'stats.png': return Icons.bar_chart;
      default: return Icons.circle;
    }
  }
}