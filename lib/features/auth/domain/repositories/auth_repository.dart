import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> signInWithEmail(String email, String password);
  Future<Either<Failure, AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required UserRole role,
  });
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, AuthUser?>> getCurrentUser();
}