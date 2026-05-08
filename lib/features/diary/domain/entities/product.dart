import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double fats;
  final double carbs;

  const Product({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
  });

  @override
  List<Object?> get props => [id, name, calories, protein, fats, carbs];
}