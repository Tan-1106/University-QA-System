import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_questions.dart';

import '../entities/existing_faculties.dart';

abstract interface class PopularQuestionsRepository {
  Future<Either<Failure, bool>> generatePopularQuestions();

  Future<Either<Failure, PopularQuestions>> loadStudentPopularQuestions({
    bool facultyOnly = false,
  });

  Future<Either<Failure, PopularQuestions>> loadAdminPopularQuestions({
    bool isDisplay = true,
    String? faculty,
  });

  Future<Either<Failure, ExistingFaculties>> loadExistingFaculties();

  Future<Either<Failure, bool>> toggleQuestionDisplayStatus(String questionId);

  Future<Either<Failure, bool>> assignFacultyScopeToQuestion(String questionId, String? faculty);

  Future<Either<Failure, bool>> updateQuestion(String questionId, String? question, String? answer);
}
