import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/user_management/domain/repositories/user_management_repository.dart';

class LoadAllRolesUseCase implements UseCase<List<String>, NoParams> {
  final UserManagementRepository userManagementRepository;

  const LoadAllRolesUseCase(this.userManagementRepository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) {
    return userManagementRepository.fetchAllRoles();
  }
}