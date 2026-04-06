enum MeasurementPeriod { day, month, year, custom }

class Measurement {
  final String id;
  final DateTime date;
  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;
  final double? weightKg;

  Measurement({
    required this.id,
    required this.date,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.weightKg,
  });

  Measurement copyWith({
    String? id,
    DateTime? date,
    double? chestCm,
    double? waistCm,
    double? hipsCm,
    double? weightKg,
  }) {
    return Measurement(
      id: id ?? this.id,
      date: date ?? this.date,
      chestCm: chestCm ?? this.chestCm,
      waistCm: waistCm ?? this.waistCm,
      hipsCm: hipsCm ?? this.hipsCm,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}