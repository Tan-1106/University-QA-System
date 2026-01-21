import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/user_management/domain/repositories/user_management_repository.dart';

class ChangeBanStatusUseCase implements UseCase<void, ChangeBanStatusParams> {
  final UserManagementRepository userManagementRepository;

  const ChangeBanStatusUseCase(this.userManagementRepository);

  @override
  Future<Either<Failure, void>> call(ChangeBanStatusParams params) {
    return userManagementRepository.changeUserBanStatus(
      userId: params.userId,
      currentBanStatus: params.currentBanStatus,
    );
  }
}

class ChangeBanStatusParams {
  final String userId;
  final bool currentBanStatus;

  const ChangeBanStatusParams({
    required this.userId,
    required this.currentBanStatus,
  });
}
