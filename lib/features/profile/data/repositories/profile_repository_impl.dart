import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_mock_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileMockDataSource mockDataSource;

  ProfileRepositoryImpl({required this.mockDataSource});

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    try {
      final profile = await mockDataSource.getProfile();
      return Right(profile);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(Profile profile) async {
    try {
      if (profile is ProfileModel) {
        await mockDataSource.updateProfile(profile);
        return const Right(null);
      }
      return Left(ServerFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}