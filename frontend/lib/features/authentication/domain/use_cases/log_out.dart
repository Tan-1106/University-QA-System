import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';

class LogOutUseCase implements UseCase<bool, NoParams> {
  final AuthRepository _authRepository;

  const LogOutUseCase(this._authRepository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return _authRepository.signOut();
  }
}