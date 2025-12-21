import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_record.dart';

abstract interface class ChatBoxRepository {
  Future<Either<Failure, QaRecord>> askQuestion(
    String question,
  );
}
