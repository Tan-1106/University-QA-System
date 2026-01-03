import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';

class LoadStudentPopularQuestionsUseCase implements UseCase<PopularQuestions, LoadStudentPopularQuestionsParams> {
  final PopularQuestionsRepository repository;

  LoadStudentPopularQuestionsUseCase(this.repository);

  @override
  Future<Either<Failure, PopularQuestions>> call(LoadStudentPopularQuestionsParams params) {
    return repository.loadStudentPopularQuestions(
      facultyOnly: params.facultyOnly,
    );
  }
}

class LoadStudentPopularQuestionsParams {
  final bool facultyOnly;

  LoadStudentPopularQuestionsParams({
    this.facultyOnly = false,
  });
}