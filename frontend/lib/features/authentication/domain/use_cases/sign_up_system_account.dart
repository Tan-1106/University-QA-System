import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';

class SignUpSystemAccountUseCase implements UseCase<void, SignUpSystemAccountParams> {
  final AuthRepository authRepository;

  SignUpSystemAccountUseCase(this.authRepository);

  // Create a system account
  @override
  Future<Either<Failure, void>> call(SignUpSystemAccountParams params) {
    return authRepository.signUpSystemAccount(
      name: params.name,
      email: params.email,
      studentId: params.studentId,
      faculty: params.faculty,
      password: params.password,
    );
  }
}

class SignUpSystemAccountParams {
  final String name;
  final String email;
  final String studentId;
  final String faculty;
  final String password;

  SignUpSystemAccountParams({
    required this.name,
    required this.email,
    required this.studentId,
    required this.faculty,
    required this.password,
  });
}
