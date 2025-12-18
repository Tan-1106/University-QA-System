import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';
import 'package:university_qa_system/features/authentication/domain/repositories/auth_repository.dart';

class UserInformation implements UseCase<User, UserInformationParams> {
  final AuthRepository authRepository;
  const UserInformation(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserInformationParams params) {
    return authRepository.getUserInformation(params.authCode);
  }
}

class UserInformationParams {
  final String authCode;

  UserInformationParams({required this.authCode});
}