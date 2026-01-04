import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';

class ToggleQuestionDisplayStatusUseCase implements UseCase<bool, ToggleQuestionDisplayStatusParams> {
  final PopularQuestionsRepository repository;

  const ToggleQuestionDisplayStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ToggleQuestionDisplayStatusParams params) async {
    return repository.toggleQuestionDisplayStatus(params.questionId);
  }
}

class ToggleQuestionDisplayStatusParams {
  final String questionId;

  ToggleQuestionDisplayStatusParams(this.questionId);
}