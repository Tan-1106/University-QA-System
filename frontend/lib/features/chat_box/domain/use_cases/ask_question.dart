import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_record.dart';
import 'package:university_qa_system/features/chat_box/domain/repositories/chat_box_repository.dart';

class AskQuestionUseCase implements UseCase<QARecord, AskQuestionParams> {
  final ChatBoxRepository chatBoxRepository;

  const AskQuestionUseCase(this.chatBoxRepository);

  @override
  Future<Either<Failure, QARecord>> call(AskQuestionParams params) {
    return chatBoxRepository.askQuestion(params.question);
  }
}

class AskQuestionParams {
  final String question;

  const AskQuestionParams({
    required this.question,
  });
}