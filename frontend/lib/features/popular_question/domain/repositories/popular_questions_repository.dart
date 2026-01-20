import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_question_list.dart';

import '../entities/faculty_list.dart';

abstract interface class PopularQuestionsRepository {
  // Compile statistics on common questions
  Future<Either<Failure, void>> generatePopularQuestions();

  // Get popular questions for students
  Future<Either<Failure, PopularQuestionListEntity>> getPopularQuestionsForStudent({
    bool facultyOnly = false,
  });

  // Get popular questions for admin
  Future<Either<Failure, PopularQuestionListEntity>> getPopularQuestionsForAdmin({
    bool isDisplay = true,
    String? faculty,
  });

  // Get list of faculties
  Future<Either<Failure, FacultyListEntity>> getFaculties();

  // Toggle question display status
  Future<Either<Failure, void>> toggleQuestionDisplayStatus({
    required String questionId,
  });

  // Assign faculty scope to question
  Future<Either<Failure, void>> assignFacultyScopeToQuestion({
    required String questionId,
    required String? faculty,
  });

  // Update question and/or answer
  Future<Either<Failure, void>> updateQuestion({
    required String questionId,
    required String? question,
    required String? answer,
  });
}
