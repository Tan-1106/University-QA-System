import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/entities/filters.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';

class GetDocumentFiltersUseCase implements UseCase<FiltersEntity, NoParams> {
  final DocumentRepository documentRepository;

 const GetDocumentFiltersUseCase(this.documentRepository);

  @override
  Future<Either<Failure, FiltersEntity>> call(NoParams params) {
    return documentRepository.getDocumentFilter();
  }
}
