import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_question_list.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';

class GetPopularQuestionsForAdminUseCase implements UseCase<PopularQuestionListEntity, GetPopularQuestionsForAdminParams> {
  final PopularQuestionsRepository repository;

  GetPopularQuestionsForAdminUseCase(this.repository);

  @override
  Future<Either<Failure, PopularQuestionListEntity>> call(GetPopularQuestionsForAdminParams params) {
    return repository.getPopularQuestionsForAdmin(
      isDisplay: params.isDisplay,
      faculty: params.faculty,
    );
  }
}

class GetPopularQuestionsForAdminParams {
  final bool isDisplay;
  final String? faculty;

  GetPopularQuestionsForAdminParams({
    this.isDisplay = true,
    this.faculty,
  });
}