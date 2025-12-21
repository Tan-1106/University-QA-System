import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/question_records.dart';
import 'package:university_qa_system/features/dashboard/domain/repositories/dashboard_repository.dart';

class LoadDashboardQuestionRecordsUseCase implements UseCase<QuestionRecords, LoadDashboardQuestionRecordsParams> {
  final DashboardRepository dashboardRepository;

  const LoadDashboardQuestionRecordsUseCase(this.dashboardRepository);

  @override
  Future<Either<Failure, QuestionRecords>> call(LoadDashboardQuestionRecordsParams params) {
    return dashboardRepository.loadQuestionRecordsData(
      page: params.page,
      feedbackType: params.feedbackType,
    );
  }
}

class LoadDashboardQuestionRecordsParams {
  final int page;
  final String? feedbackType;

  const LoadDashboardQuestionRecordsParams({
    this.page = 1,
    this.feedbackType,
  });
}