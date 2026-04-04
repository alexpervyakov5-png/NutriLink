import 'package:equatable/equatable.dart';
import '../../domain/entities/meal.dart';

abstract class DiaryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadDiaryData extends DiaryEvent {
  final DateTime date;
  LoadDiaryData({required this.date});
  
  @override
  List<Object> get props => [date];
}

class ToggleMealSection extends DiaryEvent {
  final MealType mealType;
  ToggleMealSection({required this.mealType});
  
  @override
  List<Object> get props => [mealType];
}