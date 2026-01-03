import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';

import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';

class GeneratePopularQuestionsUseCase implements UseCase<bool, NoParams> {
  final PopularQuestionsRepository repository;

  const GeneratePopularQuestionsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.generatePopularQuestions();
  }
}