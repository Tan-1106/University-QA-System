import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/faculty_list.dart';
import 'package:university_qa_system/features/popular_question/domain/repositories/popular_questions_repository.dart';


class GetFacultiesUseCase implements UseCase<FacultyListEntity, NoParams> {
  final PopularQuestionsRepository repository;

  const GetFacultiesUseCase(this.repository);

  @override
  Future<Either<Failure, FacultyListEntity>> call(NoParams params) {
    return repository.getFaculties();
  }
}