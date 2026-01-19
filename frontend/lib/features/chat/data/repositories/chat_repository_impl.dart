import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/chat/domain/entities/question.dart';
import 'package:university_qa_system/features/chat/domain/entities/question_list.dart';
import 'package:university_qa_system/features/chat/domain/entities/question_details.dart';
import 'package:university_qa_system/features/chat/domain/repositories/chat_repository.dart';
import 'package:university_qa_system/features/chat/data/data_sources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatBoxRepository {
  final ChatRemoteDataSource remoteDataSource;

  const ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, QuestionEntity>> askQuestion({
    required String question,
  }) async {
    try {
      final qaData = await remoteDataSource.askQuestion(question: question);
      return right(qaData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendFeedback({
    required String questionID,
    required String feedback,
  }) async {
    try {
      final result = await remoteDataSource.sendFeedback(
        questionID: questionID,
        feedback: feedback,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, QuestionListEntity>> getQAHistory({
    int page = 1,
  }) async {
    try {
      final qaHistoryData = await remoteDataSource.getQuestionHistory(
        page: page,
      );
      return right(qaHistoryData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, QuestionDetailsEntity>> getQARecordDetails({
    required String questionID,
  }) async {
    try {
      final qaRecordDetailsData = await remoteDataSource.getQuestionDetails(
        questionID: questionID,
      );
      return right(qaRecordDetailsData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
