import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_record.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_history.dart';
import 'package:university_qa_system/features/chat_box/domain/repositories/chat_box_repository.dart';
import 'package:university_qa_system/features/chat_box/data/data_sources/chat_box_remote_data_source.dart';



class ChatBoxRepositoryImpl implements ChatBoxRepository {
  final ChatBoxRemoteDataSource remoteDataSource;

  const ChatBoxRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, QARecord>> askQuestion(String question) async {
    try {
      final qaData = await remoteDataSource.askQuestion(question: question);
      return right(qaData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, QAHistory>> getQAHistory({int page = 1}) async {
    try {
      final qaHistoryData = await remoteDataSource.getQAHistory(page: page);
      return right(qaHistoryData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}