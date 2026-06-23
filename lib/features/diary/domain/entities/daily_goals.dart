import 'package:equatable/equatable.dart';

class DailyGoals extends Equatable {
  final int proteinTarget;
  final int fatsTarget;
  final int carbsTarget;
  final int caloriesTarget;
  
  final int proteinCurrent;
  final int fatsCurrent;
  final int carbsCurrent;
  final int caloriesCurrent;

  const DailyGoals({
    required this.proteinTarget,
    required this.fatsTarget,
    required this.carbsTarget,
    required this.caloriesTarget,
    required this.proteinCurrent,
    required this.fatsCurrent,
    required this.carbsCurrent,
    required this.caloriesCurrent,
  });

  // ✅ Конструктор для пустых целей (по умолчанию)
  const DailyGoals.empty()
      : proteinTarget = 100,
        fatsTarget = 65,
        carbsTarget = 285,
        caloriesTarget = 2500,
        proteinCurrent = 0,
        fatsCurrent = 0,
        carbsCurrent = 0,
        caloriesCurrent = 0;

  DailyGoals copyWith({
    int? proteinTarget,
    int? fatsTarget,
    int? carbsTarget,
    int? caloriesTarget,
    int? proteinCurrent,
    int? fatsCurrent,
    int? carbsCurrent,
    int? caloriesCurrent,
  }) {
    return DailyGoals(
      proteinTarget: proteinTarget ?? this.proteinTarget,
      fatsTarget: fatsTarget ?? this.fatsTarget,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      caloriesTarget: caloriesTarget ?? this.caloriesTarget,
      proteinCurrent: proteinCurrent ?? this.proteinCurrent,
      fatsCurrent: fatsCurrent ?? this.fatsCurrent,
      carbsCurrent: carbsCurrent ?? this.carbsCurrent,
      caloriesCurrent: caloriesCurrent ?? this.caloriesCurrent,
    );
  }

  @override
  List<Object?> get props => [
        proteinTarget, fatsTarget, carbsTarget, caloriesTarget,
        proteinCurrent, fatsCurrent, carbsCurrent, caloriesCurrent,
      ];
}