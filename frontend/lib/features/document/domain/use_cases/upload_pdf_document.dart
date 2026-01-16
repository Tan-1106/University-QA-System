import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';


class UploadPDFDocumentUseCase implements UseCase<void, UploadPDFDocumentParams> {
  final DocumentRepository documentRepository;

  const UploadPDFDocumentUseCase(this.documentRepository);

  @override
  Future<Either<Failure, void>> call(UploadPDFDocumentParams params) {
    return documentRepository.uploadPDFDocument(
      file: params.file,
      docType: params.documentType,
      department: params.department,
      faculty: params.faculty,
      fileUrl: params.fileUrl,
    );
  }
}

class UploadPDFDocumentParams {
  final File file;
  final String documentType;
  final String? department;
  final String? faculty;
  final String fileUrl;

  UploadPDFDocumentParams({
    required this.file,
    required this.documentType,
    this.department,
    this.faculty,
    required this.fileUrl,
  });
}