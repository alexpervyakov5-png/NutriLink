import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета из макета
  static const Color background = Color(0xFF2F2F2F);
  static const Color backgroundSecondary = Color(0xFF3F3F3F);
  static const Color card = Color(0xFF4A4A4A);
  static const Color accent = Color(0xFF69BDA0);
  static const Color accentTransparent = Color(0x69BDA0B3);
  static const Color accentLight = Color(0xFFC3F7CE);
  
  // Текст
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textHint = Colors.white54;
  
  // Прогресс
  static const Color progressProtein = Colors.green;
  static const Color progressFats = Colors.red;
  static const Color progressCarbs = Colors.orange;
  static const Color progressCalories = Colors.yellow;
}

class AppStrings {
  static const String appName = 'NutriLink';
  static const String assetIcons = 'assets/icons/';
}

// Для будущего API
class ApiConfig {
  static const String baseUrl = 'https://api.nutrilink.com';
  static const int timeoutSeconds = 30;
}