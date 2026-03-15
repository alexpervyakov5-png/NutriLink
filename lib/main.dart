import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/navigation_bloc.dart';
import 'screens/home_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/measurements_screen.dart';
void main() => runApp(const NutriLinkApp());

class NutriLinkApp extends StatelessWidget {
  const NutriLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(),
      child: MaterialApp(
        title: 'NutriLink',
        debugShowCheckedModeBanner: false,
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
      backgroundColor: const Color(0xFF3F3F3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/nutrilink.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'NutriLink',
              style: TextStyle(
                color: Color(0xFFC3F7CE),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true, 
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          switch (state.index) {
            case 0: return const HomeScreen();
            case 1: return const DiaryScreen();
            case 2: return const MeasurementsScreen();
            case 3: return const StatsScreen();
            default: return const HomeScreen();
          }
        },
      ),
      bottomNavigationBar: _BottomNavigation(),
    );
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
          backgroundColor: const Color(0xFF3F3F3F),
          selectedItemColor: const Color(0xFFC3F7CE),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/home.png',
                width: 24,
                height: 24,
                color: state.index == 0 ? const Color(0xFFC3F7CE) : Colors.grey,
              ),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/book.png',
                width: 24,
                height: 24,
                color: state.index == 1 ? const Color(0xFFC3F7CE) : Colors.grey,
              ),
              label: 'Дневник',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/measurements.png',
                width: 24,
                height: 24,
                color: state.index == 2 ? const Color(0xFFC3F7CE) : Colors.grey,
              ),
              label: 'Замеры',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/stats.png',
                width: 24,
                height: 24,
                color: state.index == 3 ? const Color(0xFFC3F7CE) : Colors.grey,
              ),
              label: 'Статистика',
            ),
          ],
        );
      },
    );
  }
}