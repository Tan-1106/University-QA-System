import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/chat_box/domain/repositories/chat_box_repository.dart';


class SendFeedbackUseCase implements UseCase<bool, SendFeedbackParams> {
  final ChatBoxRepository chatBoxRepository;

  const SendFeedbackUseCase(this.chatBoxRepository);

  @override
  Future<Either<Failure, bool>> call(SendFeedbackParams params) {
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