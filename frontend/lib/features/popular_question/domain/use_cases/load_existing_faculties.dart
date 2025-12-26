import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/existing_faculties.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';


class LoadExistingFacultiesUseCase implements UseCase<ExistingFaculties, NoParams> {
  final PopularQuestionsRepository repository;

  const LoadExistingFacultiesUseCase(this.repository);

  @override
  Future<Either<Failure, ExistingFaculties>> call(NoParams params) {
    return repository.loadExistingFaculties();
  }
}