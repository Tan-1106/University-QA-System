import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';

class SignInWithELitUseCase implements UseCase<UserEntity, SignInWithELitParams> {
  final AuthRepository authRepository;

  const SignInWithELitUseCase(this.authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithELitParams params) {
    return authRepository.signInWithELIT(
      authCode: params.authCode,
    );
  }
}

class SignInWithELitParams {
  final String authCode;

  SignInWithELitParams({
    required this.authCode,
  });
}
