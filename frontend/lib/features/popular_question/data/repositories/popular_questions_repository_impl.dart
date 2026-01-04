import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_questions.dart';
import 'package:university_qa_system/features/popular_question/data/data_sources/popular_question_data_source.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';

import '../../domain/entities/existing_faculties.dart';

class PopularQuestionsRepositoryImpl implements PopularQuestionsRepository {
  final PopularQuestionDataSource remoteDataSource;

  const PopularQuestionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, bool>> generatePopularQuestions() async {
    try {
      final result = await remoteDataSource.generatePopularQuestions();
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PopularQuestions>> loadStudentPopularQuestions({
    bool facultyOnly = false,
  }) async {
    try {
      final popularQuestionsData = await remoteDataSource.fetchPopularQuestionsForStudent(
        facultyOnly: facultyOnly,
      );
      return right(popularQuestionsData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PopularQuestions>> loadAdminPopularQuestions({
    bool isDisplay = true,
    String? faculty,
  }) async {
    try {
      final popularQuestionsData = await remoteDataSource.fetchPopularQuestionsForAdmin(
        faculty: faculty,
        isDisplay: isDisplay,
      );
      return right(popularQuestionsData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, ExistingFaculties>> loadExistingFaculties() async {
    try {
      final existingFacultiesData = await remoteDataSource.fetchFaculties();
      return right(existingFacultiesData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleQuestionDisplayStatus(String questionId) async {
    try {
      final result = await remoteDataSource.toggleQuestionDisplayStatus(questionId);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> assignFacultyScopeToQuestion(String questionId, String? faculty) async {
    try {
      final result = await remoteDataSource.assignFacultyScopeToQuestion(questionId, faculty);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateQuestion(String questionId, String? question, String? answer) async {
    try {
      final result = await remoteDataSource.updateQuestion(questionId, question, answer);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
