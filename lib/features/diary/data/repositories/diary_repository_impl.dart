import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/meal.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_mock_datasource.dart';
// import '../models/meal_model.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryMockDataSource mockDataSource;
  DiaryRepositoryImpl({required this.mockDataSource});

  @override
  Future<Either<Failure, DailyGoals>> getDailyGoals(DateTime date) async {
    try {
      return Right(await mockDataSource.getDailyGoals(date));
    } on ServerException { return Left(ServerFailure()); }
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByType(MealType type, DateTime date) async {
    try {
      return Right(await mockDataSource.getMealsByType(type, date));
    } on ServerException { return Left(ServerFailure()); }
  }
}