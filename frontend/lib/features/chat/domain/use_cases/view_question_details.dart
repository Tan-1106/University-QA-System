import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/chat/domain/entities/question_details.dart';
import 'package:university_qa_system/features/chat/domain/repositories/chat_repository.dart';

class ViewQuestionDetailsUseCase implements UseCase<QuestionDetailsEntity, ViewQuestionDetailsParams> {
  final ChatBoxRepository chatBoxRepository;

  const ViewQuestionDetailsUseCase(this.chatBoxRepository);

  @override
  Future<Either<Failure, QuestionDetailsEntity>> call(ViewQuestionDetailsParams params) {
    return chatBoxRepository.getQARecordDetails(
      questionID: params.questionID,
    );
  }
}

class ViewQuestionDetailsParams {
  final String questionID;

  const ViewQuestionDetailsParams({
    required this.questionID,
  });
}
