import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';

class SignInWithSystemAccountUseCase implements UseCase<UserEntity, SignInWithSystemAccountParams> {
  final AuthRepository authRepository;

  SignInWithSystemAccountUseCase(this.authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithSystemAccountParams params) {
    return authRepository.signInWithSystemAccount(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInWithSystemAccountParams {
  final String email;
  final String password;

  SignInWithSystemAccountParams({
    required this.email,
    required this.password,
  });
}
