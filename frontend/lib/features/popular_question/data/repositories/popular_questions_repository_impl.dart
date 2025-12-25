import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_questions.dart';
import 'package:university_qa_system/features/popular_question/data/data_sources/popular_question_data_source.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';

class PopularQuestionsRepositoryImpl implements PopularQuestionsRepository {
  final PopularQuestionDataSource remoteDataSource;

  const PopularQuestionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PopularQuestions>> loadStudentPopularQuestions({
    int page = 1,
    bool facultyOnly = false,
  }) async {
    try {
      final popularQuestionsData = await remoteDataSource.fetchPopularQuestionsForStudent(
        page: page,
        facultyOnly: facultyOnly,
      );
      return right(popularQuestionsData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
