import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';

class DeleteDocumentUseCase implements UseCase<bool, DeleteDocumentParams> {
  final DocumentRepository documentRepository;

  const DeleteDocumentUseCase(this.documentRepository);

  @override
  Future<Either<Failure, bool>> call(DeleteDocumentParams params) {
    return documentRepository.deleteDocument(params.documentId);
  }
}

class DeleteDocumentParams {
  final String documentId;

  const DeleteDocumentParams(this.documentId);
}