import 'package:equatable/equatable.dart';

class Measurement extends Equatable {
  final String id;
  final String userId;
  final DateTime measuredAt;
  final double? chestCm;      // ✅ Грудь
  final double? waistCm;      // ✅ Талия
  final double? hipsCm;       // ✅ Бёдра

  const Measurement({
    required this.id,
    required this.userId,
    required this.measuredAt,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
  });

  Measurement copyWith({
    String? id,
    String? userId,
    DateTime? measuredAt,
    double? chestCm,
    double? waistCm,
    double? hipsCm,
  }) {
    return Measurement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      measuredAt: measuredAt ?? this.measuredAt,
      chestCm: chestCm ?? this.chestCm,
      waistCm: waistCm ?? this.waistCm,
      hipsCm: hipsCm ?? this.hipsCm,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        measuredAt,
        chestCm,
        waistCm,
        hipsCm,
      ];
}