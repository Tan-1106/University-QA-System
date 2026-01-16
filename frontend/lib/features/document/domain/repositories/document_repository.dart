import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/document/domain/entities/documents.dart';
import 'package:university_qa_system/features/document/domain/entities/filters.dart';
import 'package:university_qa_system/features/document/domain/entities/pdf_bytes.dart';

abstract interface class DocumentRepository {
  Future<Either<Failure, Filters>> loadDocumentFilters();

  Future<Either<Failure, Documents>> loadGeneralDocuments({
    int page = 1,
    String? department,
    String? documentType,
    String? keyword,
  });

  Future<Either<Failure, Documents>> loadFacultyDocuments({
    int page = 1,
    String? documentType,
    String? keyword,
    String? faculty,
  });

  Future<Either<Failure, PDFBytes>> viewDocument(String documentId);

  Future<Either<Failure, bool>> deleteDocument(String documentId);
}