import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/utils/constants.dart';

// Navigation imports
import 'bloc/navigation_bloc.dart';
import 'bloc/navigation_event.dart';
import 'bloc/navigation_state.dart';

// Profile imports
import 'features/profile/data/datasources/profile_mock_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
// import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile.dart';
import 'features/profile/domain/usecases/update_profile.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';
import 'features/profile/presentation/pages/home_screen.dart';

// Diary imports
import 'features/diary/data/datasources/diary_mock_datasource.dart';
import 'features/diary/data/repositories/diary_repository_impl.dart';
// import 'features/diary/domain/repositories/diary_repository.dart';
import 'features/diary/domain/usecases/get_daily_goals.dart';
import 'features/diary/domain/usecases/get_meals_by_type.dart';
import 'features/diary/presentation/bloc/diary_bloc.dart';
import 'features/diary/presentation/bloc/diary_event.dart';
import 'features/diary/presentation/pages/diary_screen.dart';

// Другие
import 'features/measurements/presentation/pages/measurements_screen.dart';
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

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(
          create: (_) => ProfileBloc(
            getProfile: GetProfile(profileRepo),
            updateProfile: UpdateProfile(profileRepo),
          )..add(LoadProfile()),
        ),
        BlocProvider(
          create: (_) => DiaryBloc(
            getDailyGoals: GetDailyGoals(diaryRepo),
            getMealsByType: GetMealsByType(diaryRepo),
          )..add(LoadDiaryData(date: DateTime.now())),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
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
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('${AppStrings.assetIcons}nutrilink.png', width: 32, height: 32),
          const SizedBox(width: 8),
          const Text(AppStrings.appName, style: TextStyle(color: AppColors.accentLight, fontSize: 24, fontWeight: FontWeight.bold)),
        ]),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.menu, color: AppColors.textPrimary), onPressed: () {})],
      ),
      body: BlocBuilder<NavigationBloc, NavigationState>(  
        builder: (context, state) {  
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
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
              label: 'Главная'
            ),
            BottomNavigationBarItem(
              icon: _navIcon('book.png', state.index == 1), 
              label: 'Дневник'
            ),
            BottomNavigationBarItem(
              icon: _navIcon('measurements.png', state.index == 2),  
              label: 'Замеры'
            ),
            BottomNavigationBarItem(
              icon: _navIcon('stats.png', state.index == 3), 
              label: 'Статистика'
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
    color: selected ? AppColors.accentLight : Colors.grey
  );
}