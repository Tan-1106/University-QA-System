import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/chat/domain/entities/question.dart';
import 'package:university_qa_system/features/chat/domain/repositories/chat_repository.dart';

class AskQuestionUseCase implements UseCase<QuestionEntity, AskQuestionParams> {
  final ChatBoxRepository chatBoxRepository;

  const AskQuestionUseCase(this.chatBoxRepository);

  @override
  Future<Either<Failure, QuestionEntity>> call(AskQuestionParams params) {
    return chatBoxRepository.askQuestion(
      question: params.question,
    );
  }
}

class AskQuestionParams {
  final String question;

  const AskQuestionParams({
    required this.question,
  });
}
