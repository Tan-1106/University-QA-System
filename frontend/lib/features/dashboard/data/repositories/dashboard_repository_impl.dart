import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/statistic.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/question_records.dart';
import 'package:university_qa_system/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:university_qa_system/features/dashboard/data/data_sources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  const DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Statistic>> loadStatisticData() async {
    try {
      final statisticData = await remoteDataSource.fetchDashboardStatistic();
      return right(statisticData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, QuestionRecords>> loadQuestionRecordsData({
    int page = 1,
    String? feedbackType,
  }) async {
    try {
      final questionRecordsData = await remoteDataSource.fetchDashboardQuestionRecords(
        page: page,
        feedbackType: feedbackType,
      );
      return right(questionRecordsData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> respondToQuestion({
    required String questionId,
    required String response,
  }) async {
    try {
      final result = await remoteDataSource.respondToQuestion(
        questionId: questionId,
        res: response,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
