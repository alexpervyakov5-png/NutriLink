import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/meal.dart';
import '../repositories/diary_repository.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/daily_goals.dart';
class GetDailyGoals implements UseCase<Either<Failure, DailyGoals>, DateTime> {
  final DiaryRepository repository;
  GetDailyGoals(this.repository);
  @override
  Future<Either<Failure, DailyGoals>> call(DateTime params) async => await repository.getDailyGoals(params);
}