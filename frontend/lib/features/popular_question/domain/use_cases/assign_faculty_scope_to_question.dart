import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';

class AssignFacultyScopeToQuestionUseCase implements UseCase<void, AssignFacultyScopeToQuestionParams> {
  final PopularQuestionsRepository repository;

  const AssignFacultyScopeToQuestionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AssignFacultyScopeToQuestionParams params) async {
    return repository.assignFacultyScopeToQuestion(
      questionId: params.questionId,
      faculty: params.faculty,
    );
  }
}

class AssignFacultyScopeToQuestionParams {
  final String questionId;
  final String? faculty;

  AssignFacultyScopeToQuestionParams(this.questionId, this.faculty);
}
