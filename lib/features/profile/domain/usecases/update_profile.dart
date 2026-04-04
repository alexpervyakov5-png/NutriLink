import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile implements UseCase<Either<Failure, void>, Profile> {
  final ProfileRepository repository;
  UpdateProfile(this.repository);
  
  @override
  Future<Either<Failure, void>> call(Profile params) async {
    return await repository.updateProfile(params);
  }
}