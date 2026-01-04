import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';

class AssignFacultyScopeToQuestionUseCase implements UseCase<bool, AssignFacultyScopeToQuestionParams> {
  final PopularQuestionsRepository repository;

  const AssignFacultyScopeToQuestionUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(AssignFacultyScopeToQuestionParams params) async {
    return repository.assignFacultyScopeToQuestion(params.questionId, params.faculty);
  }
}

class AssignFacultyScopeToQuestionParams {
  final String questionId;
  final String? faculty;

  AssignFacultyScopeToQuestionParams(this.questionId, this.faculty);
}