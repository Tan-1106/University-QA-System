import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';

class SystemAccountRegistrationUseCase implements UseCase<bool, SystemAccountRegistrationParams> {
  final AuthRepository authRepository;

  SystemAccountRegistrationUseCase(this.authRepository);

  @override
  Future<Either<Failure, bool>> call(SystemAccountRegistrationParams params) {
    return authRepository.registerSystemAccount(
      params.name,
      params.email,
      params.studentId,
      params.faculty,
      params.password,
    );
  }
}

class SystemAccountRegistrationParams {
  final String name;
  final String email;
  final String studentId;
  final String faculty;
  final String password;

  SystemAccountRegistrationParams({
    required this.name,
    required this.email,
    required this.studentId,
    required this.faculty,
    required this.password,
  });
}
