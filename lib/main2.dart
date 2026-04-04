// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// // ❌ Удалите: import 'package:page_transition/page_transition.dart';
// import 'bloc/navigation_bloc.dart';
// import 'screens/home_screen.dart';
// import 'screens/diary_screen.dart';
// import 'screens/stats_screen.dart';
// import 'screens/measurements_screen.dart';

// void main() => runApp(const NutriLinkApp());

// class NutriLinkApp extends StatelessWidget {
//   const NutriLinkApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => NavigationBloc(),
//       child: MaterialApp(
//         title: 'NutriLink',
//         debugShowCheckedModeBanner: false,
//         home: const MainScreen(),
//       ),
//     );
//   }
// }

// class MainScreen extends StatelessWidget {
//   const MainScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF3F3F3F),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/icons/nutrilink.png',
//               width: 32,
//               height: 32,
//             ),
//             const SizedBox(width: 8),
//             const Text(
//               'NutriLink',
//               style: TextStyle(
//                 color: Color(0xFFC3F7CE),
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.menu, color: Colors.white),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       // ✅ Анимация через встроенный AnimatedSwitcher
//       body: BlocBuilder<NavigationBloc, NavigationState>(
//         builder: (context, state) {
//           return AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             transitionBuilder: (Widget child, Animation<double> animation) {
//               return FadeTransition(
//                 opacity: animation,
//                 child: child,
//               );
//             },
//             child: _buildScreen(state.index),
//           );
//         },
//       ),
//       bottomNavigationBar: _BottomNavigation(),
//     );
//   }

//   // ✅ Каждый экран с уникальным Key для корректной анимации
//   Widget _buildScreen(int index) {
//     switch (index) {
//       case 0:
//         return const HomeScreen(key: ValueKey('home'));
//       case 1:
//         return const DiaryScreen(key: ValueKey('diary'));
//       case 2:
//         return const MeasurementsScreen(key: ValueKey('measurements'));
//       case 3:
//         return const StatsScreen(key: ValueKey('stats'));
//       default:
//         return const HomeScreen(key: ValueKey('home'));
//     }
//   }
// }

// class _BottomNavigation extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<NavigationBloc, NavigationState>(
//       builder: (context, state) {
//         return BottomNavigationBar(
//           currentIndex: state.index,
//           onTap: (index) => context.read<NavigationBloc>().add(TabTapped(index)),
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: const Color(0xFF3F3F3F),
//           selectedItemColor: const Color(0xFFC3F7CE),
//           unselectedItemColor: Colors.grey,
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           items: [
//             BottomNavigationBarItem(
//               icon: Image.asset(
//                 'assets/icons/home.png',
//                 width: 24,
//                 height: 24,
//                 color: state.index == 0 ? const Color(0xFFC3F7CE) : Colors.grey,
//               ),
//               label: 'Главная',
//             ),
//             BottomNavigationBarItem(
//               icon: Image.asset(
//                 'assets/icons/book.png',
//                 width: 24,
//                 height: 24,
//                 color: state.index == 1 ? const Color(0xFFC3F7CE) : Colors.grey,
//               ),
//               label: 'Дневник',
//             ),
//             BottomNavigationBarItem(
//               icon: Image.asset(
//                 'assets/icons/measurements.png',
//                 width: 24,
//                 height: 24,
//                 color: state.index == 2 ? const Color(0xFFC3F7CE) : Colors.grey,
//               ),
//               label: 'Замеры',
//             ),
//             BottomNavigationBarItem(
//               icon: Image.asset(
//                 'assets/icons/stats.png',
//                 width: 24,
//                 height: 24,
//                 color: state.index == 3 ? const Color(0xFFC3F7CE) : Colors.grey,
//               ),
//               label: 'Статистика',
//             ),
//           ],
//         );
//       },
//     );
//   }
// }