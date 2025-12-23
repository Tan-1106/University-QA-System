import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_record_details.dart';
import 'package:university_qa_system/features/chat_box/domain/repositories/chat_box_repository.dart';

class ViewQARecordDetailsUseCase implements UseCase<QARecordDetails, ViewQaRecordDetailsParams> {
  final ChatBoxRepository chatBoxRepository;

  const ViewQARecordDetailsUseCase(this.chatBoxRepository);

  @override
  Future<Either<Failure, QARecordDetails>> call(ViewQaRecordDetailsParams params) {
    return chatBoxRepository.getQARecordDetails(questionID: params.questionID);
  }
}

class ViewQaRecordDetailsParams {
  final String questionID;

  const ViewQaRecordDetailsParams({
    required this.questionID,
  });
}
