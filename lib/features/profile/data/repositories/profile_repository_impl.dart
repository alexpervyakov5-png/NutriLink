import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_supabase_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileSupabaseDataSource supabaseDataSource;

  ProfileRepositoryImpl({required this.supabaseDataSource});

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    try {
      final result = await supabaseDataSource.getProfile();
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(Profile profile) async {
    try {
      await supabaseDataSource.updateProfile(profile);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}