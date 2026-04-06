import '../../domain/entities/stats.dart';

abstract class StatsMockDataSource {
  Future<NutritionStats> getNutritionStats(
    DateTime? startDate,
    DateTime? endDate,
  );
}

class StatsMockDataSourceImpl implements StatsMockDataSource {
  @override
  Future<NutritionStats> getNutritionStats(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock данные
    return const NutritionStats(
      protein: 333,
      fats: 333,
      carbs: 333,
      calories: 1000,
      proteinPercent: 33.3,
      fatsPercent: 33.3,
      carbsPercent: 33.3,
    );
  }
}