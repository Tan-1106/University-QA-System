import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_question_list.dart';
import 'package:university_qa_system/features/popular_question/data/data_sources/popular_question_data_source.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';

import '../../domain/entities/faculty_list.dart';

class PopularQuestionsRepositoryImpl implements PopularQuestionsRepository {
  final PopularQuestionDataSource remoteDataSource;

  const PopularQuestionsRepositoryImpl(this.remoteDataSource);

  // Compile statistics on common questions
  @override
  Future<Either<Failure, void>> generatePopularQuestions() async {
    try {
      final result = await remoteDataSource.generatePopularQuestions();
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Get popular questions for students
  @override
  Future<Either<Failure, PopularQuestionListEntity>> getPopularQuestionsForStudent({
    bool facultyOnly = false,
  }) async {
    try {
      final popularQuestionsData = await remoteDataSource.getPopularQuestionsForStudent(
        facultyOnly: facultyOnly,
      );
      return right(popularQuestionsData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Get popular questions for admin
  @override
  Future<Either<Failure, PopularQuestionListEntity>> getPopularQuestionsForAdmin({
    bool isDisplay = true,
    String? faculty,
  }) async {
    try {
      final popularQuestionsData = await remoteDataSource.getPopularQuestionsForAdmin(
        faculty: faculty,
        isDisplay: isDisplay,
      );
      return right(popularQuestionsData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Get list of faculties
  @override
  Future<Either<Failure, FacultyListEntity>> getFaculties() async {
    try {
      final existingFacultiesData = await remoteDataSource.getFaculties();
      return right(existingFacultiesData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Toggle question display status
  @override
  Future<Either<Failure, void>> toggleQuestionDisplayStatus({
    required String questionId,
  }) async {
    try {
      final result = await remoteDataSource.toggleQuestionDisplayStatus(
        questionId: questionId,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Assign faculty scope to question
  @override
  Future<Either<Failure, void>> assignFacultyScopeToQuestion({
    required String questionId,
    required String? faculty,
  }) async {
    try {
      final result = await remoteDataSource.assignFacultyScopeToQuestion(
        questionId: questionId,
        faculty: faculty,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Update question and/or answer
  @override
  Future<Either<Failure, void>> updateQuestion({
    required String questionId,
    required String? question,
    required String? answer,
  }) async {
    try {
      final result = await remoteDataSource.updateQuestion(
        questionId: questionId,
        question: question,
        answer: answer,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
