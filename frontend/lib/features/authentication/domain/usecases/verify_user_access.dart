import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';

class VerifyUserAccess implements UseCase<User, NoParams> {
  final AuthRepository authRepository;
  const VerifyUserAccess(this.authRepository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return Future.value(authRepository.getUserInformation());
  }
}