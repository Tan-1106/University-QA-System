import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/user_management/domain/entities/user_list.dart';
import 'package:university_qa_system/features/user_management/domain/repositories/user_management_repository.dart';

class GetUsersUseCase implements UseCase<UserListEntity, GetUsersParams> {
  final UserManagementRepository userManagementRepository;

  const GetUsersUseCase(this.userManagementRepository);

  @override
  Future<Either<Failure, UserListEntity>> call(GetUsersParams params) {
    return userManagementRepository.getAllUsers(
      page: params.page,
      role: params.role,
      faculty: params.faculty,
      banned: params.banned,
      keyword: params.keyword,
    );
  }
}

class GetUsersParams {
  final int page;
  final String? role;
  final String? faculty;
  final bool? banned;
  final String? keyword;

  const GetUsersParams({
    this.page = 1,
    this.role,
    this.faculty,
    this.banned,
    this.keyword,
  });
}