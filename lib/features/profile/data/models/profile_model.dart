import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  ProfileModel({
    super.id,
    required super.firstName,
    required super.lastName,
    super.birthDate,
    super.heightCm,
    super.gender,
    required super.goal,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      heightCm: json['height_cm']?.toInt(),
      gender: json['gender'],
      goal: _parseGoal(json['goal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate?.toIso8601String(),
      'height_cm': heightCm,
      'gender': gender,
      'goal': goal.toString().split('.').last,
    };
  }

  static GoalType _parseGoal(String? goalStr) {
    if (goalStr == null) return GoalType.maintenance;
    try {
      return GoalType.values.firstWhere(
        (e) => e.toString().split('.').last == goalStr,
        orElse: () => GoalType.maintenance,
      );
    } catch (_) {
      return GoalType.maintenance;
    }
  }
}