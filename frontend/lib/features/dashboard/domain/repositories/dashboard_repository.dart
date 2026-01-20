import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/dashboard_question_list.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/dashboard_statistics.dart';

abstract interface class DashboardRepository {
  // Get dashboard statistics
  Future<Either<Failure, DashboardStatisticsEntity>> getStatistics();

  // Get list of questions with optional pagination and feedback type filtering
  Future<Either<Failure, DashboardQuestionListEntity>> getQuestions({
    int page = 1,
    String? feedbackType,
  });

  // Respond to a specific question
  Future<Either<Failure, void>> respondToQuestion({
    required String questionId,
    required String response,
  });
}