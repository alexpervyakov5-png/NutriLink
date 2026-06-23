import 'package:equatable/equatable.dart';

class Measurement extends Equatable {
  final String id;
  final String userId;
  final DateTime measuredAt;
  final double? weightKg;
  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;

  const Measurement({
    required this.id,
    required this.userId,
    required this.measuredAt,
    this.weightKg,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
  });

  Measurement copyWith({
    String? id,
    String? userId,
    DateTime? measuredAt,
    double? weightKg,
    double? chestCm,
    double? waistCm,
    double? hipsCm,
  }) {
    return Measurement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      measuredAt: measuredAt ?? this.measuredAt,
      weightKg: weightKg ?? this.weightKg,
      chestCm: chestCm ?? this.chestCm,
      waistCm: waistCm ?? this.waistCm,
      hipsCm: hipsCm ?? this.hipsCm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'measured_at': measuredAt.toIso8601String(),
      'weight_kg': weightKg,
      'chest_cm': chestCm,
      'waist_cm': waistCm,
      'hips_cm': hipsCm,
    };
  }

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      measuredAt: DateTime.parse(json['measured_at'] as String),
      weightKg: _toDouble(json['weight_kg']),
      chestCm: _toDouble(json['chest_cm']),
      waistCm: _toDouble(json['waist_cm']),
      hipsCm: _toDouble(json['hips_cm']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [id, userId, measuredAt, weightKg, chestCm, waistCm, hipsCm];
}