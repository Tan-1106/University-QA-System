import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/document/domain/entities/filters.dart';
import 'package:university_qa_system/features/document/domain/entities/documents.dart';
import 'package:university_qa_system/features/document/data/data_sources/document_remote_data_source.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';


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
  Future<Either<Failure, Documents>> loadGeneralDocuments({
    String? department,
    String? documentType,
    String? keyword,
  }) async {
    try {
      final documentsData = await remoteDataSource.fetchGeneralDocuments(
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
    String? documentType,
    String? keyword,
  }) async {
    try {
      final documentsData = await remoteDataSource.fetchFacultyDocuments(
        docType: documentType,
        keyword: keyword,
      );
      return right(documentsData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
