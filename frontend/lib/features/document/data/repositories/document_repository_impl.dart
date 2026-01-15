import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/document/domain/entities/filters.dart';
import 'package:university_qa_system/features/document/domain/entities/pdf_bytes.dart';
import 'package:university_qa_system/features/document/domain/entities/documents.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';
import 'package:university_qa_system/features/document/data/data_sources/document_remote_data_source.dart';



class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;

  const DocumentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Filters>> loadDocumentFilters() async {
    try {
      final filtersData = await remoteDataSource.fetchDocumentFilters();
      return right(filtersData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> loadAllFaculties() async {
    try {
      final faculties = await remoteDataSource.fetchAllFaculties();
      return right(faculties);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Documents>> loadGeneralDocuments({
    int page = 1,
    String? department,
    String? documentType,
    String? keyword,
  }) async {
    try {
      final documentsData = await remoteDataSource.fetchGeneralDocuments(
        page: page,
        department: department,
        docType: documentType,
        keyword: keyword,
      );
      return right(documentsData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Documents>> loadFacultyDocuments({
    int page = 1,
    String? documentType,
    String? keyword,
  }) async {
    try {
      final documentsData = await remoteDataSource.fetchFacultyDocuments(
        page: page,
        docType: documentType,
        keyword: keyword,
      );
      return right(documentsData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PDFBytes>> viewDocument(String documentId) async {
    try {
      final pdfBytesData = await remoteDataSource.viewDocument(documentId);
      return right(pdfBytesData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDocument(String documentId) async {
    try {
      final result = await remoteDataSource.deleteDocument(documentId);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
