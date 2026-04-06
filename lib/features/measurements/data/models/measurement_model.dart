import '../../domain/entities/measurement.dart';

class MeasurementModel extends Measurement {
  MeasurementModel({
    required super.id,
    required super.date,
    super.chestCm,
    super.waistCm,
    super.hipsCm,
    super.weightKg,
  });

  factory MeasurementModel.fromJson(Map<String, dynamic> json) {
    return MeasurementModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      chestCm: json['chest_cm']?.toDouble(),
      waistCm: json['waist_cm']?.toDouble(),
      hipsCm: json['hips_cm']?.toDouble(),
      weightKg: json['weight_kg']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'chest_cm': chestCm,
      'waist_cm': waistCm,
      'hips_cm': hipsCm,
      'weight_kg': weightKg,
    };
  }
}