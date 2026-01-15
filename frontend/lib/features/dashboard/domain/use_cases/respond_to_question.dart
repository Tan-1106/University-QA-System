import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/dashboard/domain/repositories/dashboard_repository.dart';

class RespondToQuestionUseCase implements UseCase<bool, RespondToQuestionUseCaseParams> {
  final DashboardRepository dashboardRepository;

  const RespondToQuestionUseCase(this.dashboardRepository);

  @override
  Future<Either<Failure, bool>> call(RespondToQuestionUseCaseParams params) {
    return dashboardRepository.respondToQuestion(
      questionId: params.questionId,
      response: params.response,
    );
  }
}

class RespondToQuestionUseCaseParams {
  final String questionId;
  final String response;

  RespondToQuestionUseCaseParams({
    required this.questionId,
    required this.response,
  });
}
