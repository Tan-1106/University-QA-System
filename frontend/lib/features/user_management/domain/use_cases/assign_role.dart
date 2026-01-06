import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/user_management/domain/repositories/user_management_repository.dart';

class AssignRoleUseCase implements UseCase<bool, AssignRoleUseCaseParams> {
  final UserManagementRepository userManagementRepository;

  const AssignRoleUseCase(this.userManagementRepository);

  @override
  Future<Either<Failure, bool>> call(AssignRoleUseCaseParams params) {
    return userManagementRepository.assignRole(
      params.userId,
      params.roleToAssign,
      params.faculty,
    );
  }
}

class AssignRoleUseCaseParams {
  final String userId;
  final String roleToAssign;
  final String? faculty;

  const AssignRoleUseCaseParams({
    required this.userId,
    required this.roleToAssign,
    this.faculty,
  });
}
