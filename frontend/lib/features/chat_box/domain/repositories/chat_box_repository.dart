import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_history.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_record.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_record_details.dart';

abstract interface class ChatBoxRepository {
  Future<Either<Failure, QARecord>> askQuestion(
    String question,
  );

  Future<Either<Failure, bool>> sendFeedback({
    required String questionID,
    required String feedback,
  });

  Future<Either<Failure, QAHistory>> getQAHistory({
    int page,
  });

  Future<Either<Failure, QARecordDetails>> getQARecordDetails({
    required String questionID,
  });
}
