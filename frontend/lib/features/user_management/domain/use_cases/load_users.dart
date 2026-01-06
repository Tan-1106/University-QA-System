import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/user_management/domain/entities/users.dart';
import 'package:university_qa_system/features/user_management/domain/repositories/user_management_repository.dart';

class LoadUsersUseCase implements UseCase<Users, LoadUsersUseCaseParams> {
  final UserManagementRepository userManagementRepository;

  const LoadUsersUseCase(this.userManagementRepository);

  @override
  Future<Either<Failure, Users>> call(LoadUsersUseCaseParams params) {
    return userManagementRepository.fetchAllUsers(
      page: params.page,
      role: params.role,
      faculty: params.faculty,
      banned: params.banned,
      keyword: params.keyword,
    );
  }
}

class LoadUsersUseCaseParams {
  final int page;
  final String? role;
  final String? faculty;
  final bool? banned;
  final String? keyword;

  const LoadUsersUseCaseParams({
    this.page = 1,
    this.role,
    this.faculty,
    this.banned,
    this.keyword,
  });
}