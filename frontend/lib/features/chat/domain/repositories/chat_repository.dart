import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/chat/domain/entities/question.dart';
import 'package:university_qa_system/features/chat/domain/entities/question_list.dart';
import 'package:university_qa_system/features/chat/domain/entities/question_details.dart';

abstract interface class ChatBoxRepository {
  Future<Either<Failure, QuestionEntity>> askQuestion({
    required String question,
  });

  Future<Either<Failure, void>> sendFeedback({
    required String questionID,
    required String feedback,
  });

  Future<Either<Failure, QuestionListEntity>> getQAHistory({
    int page,
  });

  Future<Either<Failure, QuestionDetailsEntity>> getQARecordDetails({
    required String questionID,
  });
}
