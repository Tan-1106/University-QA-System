import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/dashboard_statistics.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/dashboard_question_list.dart';
import 'package:university_qa_system/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:university_qa_system/features/dashboard/data/data_sources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  const DashboardRepositoryImpl(this.remoteDataSource);

  // Get dashboard statistics
  @override
  Future<Either<Failure, DashboardStatisticsEntity>> getStatistics() async {
    try {
      final statisticData = await remoteDataSource.getStatistics();
      return right(statisticData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Get list of questions with optional pagination and feedback type filtering
  @override
  Future<Either<Failure, DashboardQuestionListEntity>> getQuestions({
    int page = 1,
    String? feedbackType,
  }) async {
    try {
      final questionRecordsData = await remoteDataSource.getQuestions(
        page: page,
        feedbackType: feedbackType,
      );
      return right(questionRecordsData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Respond to a specific question
  @override
  Future<Either<Failure, void>> respondToQuestion({
    required String questionId,
    required String response,
  }) async {
    try {
      final result = await remoteDataSource.respondToQuestion(
        questionId: questionId,
        adminResponse: response,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
