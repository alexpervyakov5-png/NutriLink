import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(children: [
        AppBar(
          backgroundColor: Colors.transparent, 
          elevation: 0, 
          centerTitle: true,
          title: const Text('Замеры', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold))
        ),
        Expanded(
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.straighten, size: 64, color: AppColors.accent), 
              
              const SizedBox(height: 16),
              const Text('Замеры тела', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('Данные появятся после первого замера', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {}, 
                icon: const Icon(Icons.add), 
                label: const Text('Добавить замер'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black)
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}