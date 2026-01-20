import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';

class UpdateQuestionUseCase implements UseCase<void, UpdateQuestionParams> {
  final PopularQuestionsRepository repository;

  const UpdateQuestionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateQuestionParams params) async {
    return repository.updateQuestion(
      questionId: params.questionId,
      question: params.question,
      answer: params.answer,
    );
  }
}

class UpdateQuestionParams {
  final String questionId;
  final String? question;
  final String? answer;

  UpdateQuestionParams(this.questionId, this.question, this.answer);
}
