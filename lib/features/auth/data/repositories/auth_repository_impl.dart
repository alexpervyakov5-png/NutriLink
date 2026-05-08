import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_supabase_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthSupabaseDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, AuthUser>> signInWithEmail(String email, String password) async {
    try {
      final user = await dataSource.signInWithEmail(email, password);
      return Right(user);
    } on ServerException {
      return Left(ServerFailure()); // ✅ Без аргументов
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required UserRole role,
  }) async {
    try {
      final user = await dataSource.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        role: role,
      );
      return Right(user);
    } on ServerException {
      return Left(ServerFailure()); // ✅ Без аргументов
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await dataSource.signOut();
      return const Right(null);
    } catch (_) {
      return Left(ServerFailure()); // ✅ Без аргументов
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      final user = await dataSource.getCurrentUser();
      return Right(user);
    } catch (_) {
      return Left(ServerFailure()); // ✅ Без аргументов
    }
  }
}