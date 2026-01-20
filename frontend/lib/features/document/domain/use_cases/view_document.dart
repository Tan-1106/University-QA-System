import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/entities/pdf_bytes.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';

class ViewDocumentUseCase implements UseCase<PDFBytes, ViewDocumentParams> {
  final DocumentRepository documentRepository;

  const ViewDocumentUseCase(this.documentRepository);

  @override
  Future<Either<Failure, PDFBytes>> call(ViewDocumentParams params) {
    return documentRepository.viewDocument(
      documentId: params.documentId,
    );
  }
}

class ViewDocumentParams {
  final String documentId;

  const ViewDocumentParams(this.documentId);
}
