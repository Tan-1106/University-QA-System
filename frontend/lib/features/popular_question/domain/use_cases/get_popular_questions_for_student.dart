import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_question_list.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';

class GetPopularQuestionsForStudentUseCase implements UseCase<PopularQuestionListEntity, GetPopularQuestionsForStudentParams> {
  final PopularQuestionsRepository repository;

  GetPopularQuestionsForStudentUseCase(this.repository);

  @override
  Future<Either<Failure, PopularQuestionListEntity>> call(GetPopularQuestionsForStudentParams params) {
    return repository.getPopularQuestionsForStudent(
      facultyOnly: params.facultyOnly,
    );
  }
}

class GetPopularQuestionsForStudentParams {
  final bool facultyOnly;

  GetPopularQuestionsForStudentParams({
    this.facultyOnly = false,
  });
}