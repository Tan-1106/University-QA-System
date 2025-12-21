import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/question_records.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/statistic.dart';

abstract interface class DashboardRepository {
  Future<Either<Failure, Statistic>> loadStatisticData();
  Future<Either<Failure, QuestionRecords>> loadQuestionRecordsData({
    int page = 1,
    String? feedbackType,
  });
}