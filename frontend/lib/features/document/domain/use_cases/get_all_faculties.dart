import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';

class GetAllFacultiesUseCase implements UseCase<List<String>, NoParams> {
  final DocumentRepository documentRepository;

  const GetAllFacultiesUseCase(this.documentRepository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) {
    return documentRepository.loadAllFaculties();
  }
}