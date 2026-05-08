import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/meal.dart';
import '../repositories/diary_repository.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/daily_goals.dart';
class GetMealsByTypeParams extends Equatable {
  final MealType type;
  final DateTime date;
  const GetMealsByTypeParams({required this.type, required this.date});
  @override
  List<Object> get props => [type, date];
}

class GetMealsByType implements UseCase<Either<Failure, List<Meal>>, GetMealsByTypeParams> {
  final DiaryRepository repository;
  GetMealsByType(this.repository);
  @override
  Future<Either<Failure, List<Meal>>> call(GetMealsByTypeParams params) async => 
    await repository.getMealsByType(params.type, params.date);
}