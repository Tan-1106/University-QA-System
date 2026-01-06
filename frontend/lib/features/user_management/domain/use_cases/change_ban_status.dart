import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/user_management/domain/repositories/user_management_repository.dart';

class ChangeBanStatusUseCase implements UseCase<bool, ChangeBanStatusUseCaseParams> {
  final UserManagementRepository userManagementRepository;

  const ChangeBanStatusUseCase(this.userManagementRepository);

  @override
  Future<Either<Failure, bool>> call(ChangeBanStatusUseCaseParams params) {
    return userManagementRepository.changeUserBanStatus(
      params.userId,
      params.currentBanStatus,
    );
  }
}

class ChangeBanStatusUseCaseParams {
  final String userId;
  final bool currentBanStatus;

  const ChangeBanStatusUseCaseParams({
    required this.userId,
    required this.currentBanStatus,
  });
}
