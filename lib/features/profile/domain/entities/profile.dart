enum GoalType { weightLoss, maintenance, muscleGain }

class Profile {
  final String? id;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final int? heightCm;
  final String? gender;
  final GoalType goal;

  Profile({
    this.id,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.heightCm,
    this.gender,
    required this.goal,
  });

  Profile copyWith({
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    int? heightCm,
    String? gender,
    GoalType? goal,
  }) {
    return Profile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
    );
  }
}