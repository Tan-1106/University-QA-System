import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/chat/domain/entities/question_list.dart';
import 'package:university_qa_system/features/chat/domain/repositories/chat_repository.dart';

class GetQuestionHistoryUseCase implements UseCase<QuestionListEntity, GetQuestionHistoryParams> {
  final ChatBoxRepository chatBoxRepository;

  const GetQuestionHistoryUseCase(this.chatBoxRepository);

  @override
  Future<Either<Failure, QuestionListEntity>> call(GetQuestionHistoryParams params) {
    return chatBoxRepository.getQAHistory(
      page: params.page,
    );
  }
}

class GetQuestionHistoryParams {
 final int page;

  const GetQuestionHistoryParams({
    this.page = 1,
  });
}