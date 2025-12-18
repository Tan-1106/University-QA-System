import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';

class SignInWithELIT implements UseCase<User, VerifyParams> {
  final AuthRepository authRepository;
  const SignInWithELIT(this.authRepository);

  @override
  Future<Either<Failure, User>> call(VerifyParams params) {
    return authRepository.signInWithELIT(params.authCode);
  }
}

class VerifyParams {
  final String authCode;

  VerifyParams({required this.authCode});
}