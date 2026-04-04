import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(children: [
        AppBar(backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
          title: const Text('Статистика', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold))),
        Expanded(
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.bar_chart, size: 64, color: AppColors.accent),
              const SizedBox(height: 16),
              const Text('Статистика питания', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('Графики появятся после заполнения дневника', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ]),
          ),
        ),
      ]),
    );
  }
}