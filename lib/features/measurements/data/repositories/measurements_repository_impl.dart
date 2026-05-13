import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/repositories/measurements_repository.dart';
import '../datasources/measurements_supabase_datasource.dart';

class MeasurementsRepositoryImpl implements MeasurementsRepository {
  final MeasurementsSupabaseDataSource dataSource;

  MeasurementsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<Measurement>>> getMeasurements({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    debugPrint('🔍 Repository: getMeasurements');
    
    try {
      final actualUserId = userId ?? SupabaseConfig.currentUserId;
      debugPrint('  userId: $actualUserId');
      
      if (actualUserId == null || actualUserId.isEmpty) {
        debugPrint('❌ Repository: userId is null or empty!');
        return Left(ServerFailure());
      }
      
      final result = await dataSource.getMeasurements(
        userId: actualUserId,
        startDate: startDate,
        endDate: endDate,
      );
      debugPrint('✅ Repository: getMeasurements успешно, ${result.length} записей');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Repository: getMeasurements ServerException: $e');
      return Left(ServerFailure());
    } catch (e, stack) {
      debugPrint('❌ Repository: getMeasurements ошибка: $e');
      debugPrint('📋 Stack: $stack');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveMeasurement(Measurement measurement) async {
    debugPrint('🔍 Repository: saveMeasurement');
    debugPrint('  входящий userId: ${measurement.userId}');
    
    try {
      final actualUserId = SupabaseConfig.currentUserId;
      debugPrint('  SupabaseConfig.currentUserId: $actualUserId');
      
      if (actualUserId == null || actualUserId.isEmpty) {
        debugPrint('❌ Repository: Пользователь не авторизован!');
        return Left(ServerFailure());
      }
      
      final measurementWithUser = Measurement(
        id: measurement.id,
        userId: actualUserId,
        measuredAt: measurement.measuredAt,
        chestCm: measurement.chestCm,
        waistCm: measurement.waistCm,
        hipsCm: measurement.hipsCm,
      );
      
      debugPrint('📤 Repository: Вызываем dataSource.saveMeasurement');
      debugPrint('  с userId: ${measurementWithUser.userId}');
      
      await dataSource.saveMeasurement(measurementWithUser);
      debugPrint('✅ Repository: saveMeasurement успешно');
      return const Right(null);
    } on ServerException catch (e) {
      debugPrint('❌ Repository: saveMeasurement ServerException: $e');
      return Left(ServerFailure());
    } catch (e, stack) {
      debugPrint('❌ Repository: saveMeasurement ошибка: $e');
      debugPrint('📋 Stack: $stack');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateMeasurement(Measurement measurement) async {
    debugPrint('🔍 Repository: updateMeasurement');
    debugPrint('  id: ${measurement.id}');
    
    try {
      await dataSource.updateMeasurement(measurement);
      debugPrint('✅ Repository: updateMeasurement успешно');
      return const Right(null);
    } on ServerException catch (e) {
      debugPrint('❌ Repository: updateMeasurement ServerException: $e');
      return Left(ServerFailure());
    } catch (e, stack) {
      debugPrint('❌ Repository: updateMeasurement ошибка: $e');
      debugPrint('📋 Stack: $stack');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteMeasurement(String id) async {
    debugPrint('🔍 Repository: deleteMeasurement');
    debugPrint('  id: $id');
    
    try {
      await dataSource.deleteMeasurement(id);
      debugPrint('✅ Repository: deleteMeasurement успешно');
      return const Right(null);
    } on ServerException catch (e) {
      debugPrint('❌ Repository: deleteMeasurement ServerException: $e');
      return Left(ServerFailure());
    } catch (e, stack) {
      debugPrint('❌ Repository: deleteMeasurement ошибка: $e');
      debugPrint('📋 Stack: $stack');
      return Left(ServerFailure());
    }
  }
}