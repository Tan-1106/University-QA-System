import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/document/domain/entities/documents.dart';
import 'package:university_qa_system/features/document/domain/entities/filters.dart';

abstract interface class DocumentRepository {
  Future<Either<Failure, Filters>> loadDocumentFilters();
  Future<Either<Failure, Documents>> loadGeneralDocuments({
    String? department,
    String? documentType,
    String? keyword,
  });
  Future<Either<Failure, Documents>> loadFacultyDocuments({
    String? documentType,
    String? keyword,
  });
}