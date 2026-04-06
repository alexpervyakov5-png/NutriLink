import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/utils/constants.dart';

// ✅ Navigation
import 'bloc/navigation_bloc.dart';
import 'bloc/navigation_event.dart';
import 'bloc/navigation_state.dart';

// ✅ Profile
import 'features/profile/data/datasources/profile_mock_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile.dart';
import 'features/profile/domain/usecases/update_profile.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';
import 'features/profile/presentation/pages/home_screen.dart';

// ✅ Diary
import 'features/diary/data/datasources/diary_mock_datasource.dart';
import 'features/diary/data/repositories/diary_repository_impl.dart';
import 'features/diary/domain/repositories/diary_repository.dart';
import 'features/diary/domain/usecases/get_daily_goals.dart';
import 'features/diary/domain/usecases/get_meals_by_type.dart';
import 'features/diary/presentation/bloc/diary_bloc.dart';
import 'features/diary/presentation/bloc/diary_event.dart';
import 'features/diary/presentation/pages/diary_screen.dart';

// ✅ Measurements
import 'features/measurements/data/datasources/measurements_mock_datasource.dart';
import 'features/measurements/data/repositories/measurements_repository_impl.dart';
import 'features/measurements/domain/repositories/measurements_repository.dart';
import 'features/measurements/domain/usecases/get_measurements.dart';
import 'features/measurements/domain/usecases/save_measurement.dart';
import 'features/measurements/domain/entities/measurement.dart';
import 'features/measurements/presentation/bloc/measurements_bloc.dart';
import 'features/measurements/presentation/bloc/measurements_event.dart';
import 'features/measurements/presentation/pages/measurements_screen.dart';

// ✅ Stats — ПОЛНЫЙ набор импортов
import 'features/stats/data/datasources/stats_mock_datasource.dart';
import 'features/stats/data/repositories/stats_repository_impl.dart';
import 'features/stats/domain/repositories/stats_repository.dart';
import 'features/stats/domain/usecases/get_nutrition_stats.dart';
import 'features/stats/presentation/bloc/stats_bloc.dart';
import 'features/stats/presentation/bloc/stats_event.dart';
import 'features/stats/presentation/bloc/stats_state.dart';
import 'features/stats/presentation/pages/stats_screen.dart';

void main() => runApp(const NutriLinkApp());

class NutriLinkApp extends StatelessWidget {
  const NutriLinkApp({super.key});

  @override
  Widget build(BuildContext context) {

    final profileMockDs = ProfileMockDataSourceImpl();
    final profileRepo = ProfileRepositoryImpl(mockDataSource: profileMockDs);
    
    final diaryMockDs = DiaryMockDataSourceImpl();
    final diaryRepo = DiaryRepositoryImpl(mockDataSource: diaryMockDs);
    
    final measurementsMockDs = MeasurementsMockDataSourceImpl();
    final measurementsRepo = MeasurementsRepositoryImpl(mockDataSource: measurementsMockDs);
    
    // ✅ Stats dependencies
    final statsMockDs = StatsMockDataSourceImpl();
    final statsRepo = StatsRepositoryImpl(mockDataSource: statsMockDs);

    return MultiBlocProvider(
      providers: [
        // 🧭 Navigation
        BlocProvider(create: (_) => NavigationBloc()),
        
        // 👤 Profile
        BlocProvider(
          create: (_) => ProfileBloc(
            getProfile: GetProfile(profileRepo),
            updateProfile: UpdateProfile(profileRepo),
          )..add(LoadProfile()),
        ),
        
        // 📓 Diary
        BlocProvider(
          create: (_) => DiaryBloc(
            getDailyGoals: GetDailyGoals(diaryRepo),
            getMealsByType: GetMealsByType(diaryRepo),
          )..add(LoadDiaryData(date: DateTime.now())),
        ),
        
        // 📏 Measurements
        BlocProvider(
          create: (_) => MeasurementsBloc(
            getMeasurements: GetMeasurements(measurementsRepo),
            saveMeasurement: SaveMeasurement(measurementsRepo),
          )..add(LoadMeasurements(period: MeasurementPeriod.day)),
        ),
        

        BlocProvider(
          create: (_) => StatsBloc(
            getNutritionStats: GetNutritionStats(statsRepo),
          )..add(LoadStats(period: MeasurementPeriod.day)), 
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent, 
            elevation: 0,
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

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
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation, 
              child: child,
            ),
            child: _buildScreen(state.index),
          );
        },
      ),
      bottomNavigationBar: _BottomNavigation(),
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
}

class _BottomNavigation extends StatelessWidget {
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
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: _navIcon('book.png', state.index == 1),
              label: 'Дневник',
            ),
            BottomNavigationBarItem(
              icon: _navIcon('measurements.png', state.index == 2),
              label: 'Замеры',
            ),
            BottomNavigationBarItem(
              icon: _navIcon('stats.png', state.index == 3),
              label: 'Статистика',
            ),
          ],
        );
      },
    );
  }

  Widget _navIcon(String name, bool selected) => Image.asset(
    '${AppStrings.assetIcons}$name', 
    width: 24, 
    height: 24,
    color: selected ? AppColors.accentLight : Colors.grey,
  );
}