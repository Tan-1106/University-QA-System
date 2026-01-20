import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/dashboard_question_list.dart';
import 'package:university_qa_system/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetQuestionsUseCase implements UseCase<DashboardQuestionListEntity, GetQuestionsParams> {
  final DashboardRepository dashboardRepository;

  const GetQuestionsUseCase(this.dashboardRepository);

  @override
  Future<Either<Failure, DashboardQuestionListEntity>> call(GetQuestionsParams params) {
    return dashboardRepository.getQuestions(
      page: params.page,
      feedbackType: params.feedbackType,
    );
  }
}

class GetQuestionsParams {
  final int page;
  final String? feedbackType;

  const GetQuestionsParams({
    this.page = 1,
    this.feedbackType,
  });
}