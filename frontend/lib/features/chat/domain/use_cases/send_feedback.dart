import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/chat/domain/repositories/chat_repository.dart';


class SendFeedbackUseCase implements UseCase<void, SendFeedbackParams> {
  final ChatBoxRepository chatBoxRepository;

  const SendFeedbackUseCase(this.chatBoxRepository);

  @override
  Future<Either<Failure, void>> call(SendFeedbackParams params) {
    return chatBoxRepository.sendFeedback(
      questionID: params.questionID,
      feedback: params.feedback,
    );
  }
}

class SendFeedbackParams {
  final String questionID;
  final String feedback;

  const SendFeedbackParams({
    required this.questionID,
    required this.feedback,
  });
}