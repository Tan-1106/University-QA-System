import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/user_management/domain/repositories/user_management_repository.dart';

class AssignRoleUseCase implements UseCase<void, AssignRoleParams> {
  final UserManagementRepository userManagementRepository;

  const AssignRoleUseCase(this.userManagementRepository);

  @override
  Future<Either<Failure, void>> call(AssignRoleParams params) {
    return userManagementRepository.assignRole(
      userId: params.userId,
      roleToAssign: params.roleToAssign,
      faculty: params.faculty,
    );
  }
}

class AssignRoleParams {
  final String userId;
  final String roleToAssign;
  final String? faculty;

  const AssignRoleParams({
    required this.userId,
    required this.roleToAssign,
    this.faculty,
  });
}
