import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/entities/filters.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';

class GetExistingFiltersUseCase implements UseCase<Filters, NoParams> {
  final DocumentRepository documentRepository;

 const GetExistingFiltersUseCase(this.documentRepository);

  @override
  Future<Either<Failure, Filters>> call(NoParams params) {
    return documentRepository.loadDocumentFilters();
  }
}
