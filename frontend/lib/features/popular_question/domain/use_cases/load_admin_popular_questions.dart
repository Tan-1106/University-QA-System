import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';

class LoadAdminPopularQuestionsUseCase implements UseCase<PopularQuestions, LoadAdminPopularQuestionsParams> {
  final PopularQuestionsRepository repository;

  LoadAdminPopularQuestionsUseCase(this.repository);

  @override
  Future<Either<Failure, PopularQuestions>> call(LoadAdminPopularQuestionsParams params) {
    return repository.loadAdminPopularQuestions(
      isDisplay: params.isDisplay,
      faculty: params.faculty,
    );
  }
}

class LoadAdminPopularQuestionsParams {
  final bool isDisplay;
  final String? faculty;

  LoadAdminPopularQuestionsParams({
    this.isDisplay = true,
    this.faculty,
  });
}