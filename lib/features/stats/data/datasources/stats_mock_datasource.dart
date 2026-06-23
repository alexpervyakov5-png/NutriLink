// import '../../../../core/error/exceptions.dart';
// import '../../domain/entities/stats.dart';

// abstract class StatsMockDataSource {
//   Future<NutritionStats> getNutritionStats({
//     DateTime? startDate,
//     DateTime? endDate,
//   });
// }

// class StatsMockDataSourceImpl implements StatsMockDataSource {
//   @override
//   Future<NutritionStats> getNutritionStats({
//     DateTime? startDate,
//     DateTime? endDate,
//   }) async {
//     await Future.delayed(const Duration(milliseconds: 300));
    
//     // ✅ Возвращаем моковые данные
//     return const NutritionStats(
//       protein: 85,
//       fats: 45,
//       carbs: 200,
//       calories: 1800,
//       proteinPercent: 19.0,
//       fatsPercent: 23.0,
//       carbsPercent: 58.0,
//     );
//   }
// }