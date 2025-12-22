import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_history.dart';
import 'package:university_qa_system/features/chat_box/domain/repositories/chat_box_repository.dart';

class GetQAHistoryUseCase implements UseCase<QAHistory, GetQAHistoryParams> {
  final ChatBoxRepository chatBoxRepository;

  const GetQAHistoryUseCase(this.chatBoxRepository);

  @override
  Future<Either<Failure, QAHistory>> call(GetQAHistoryParams params) {
    return chatBoxRepository.getQAHistory(
      page: params.page,
    );
  }
}

class GetQAHistoryParams {
 final int page;

  const GetQAHistoryParams({
    this.page = 1,
  });
}