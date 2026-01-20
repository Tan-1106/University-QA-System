import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/document/domain/entities/filters.dart';
import 'package:university_qa_system/features/document/domain/entities/pdf_bytes.dart';
import 'package:university_qa_system/features/document/domain/entities/document_list.dart';
import 'package:university_qa_system/features/document/domain/repositories/document_repository.dart';
import 'package:university_qa_system/features/document/data/data_sources/document_remote_data_source.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;

  const DocumentRepositoryImpl(this.remoteDataSource);

  // Retrieves document filters such as departments, document types, and faculties
  @override
  Future<Either<Failure, FiltersEntity>> getDocumentFilter() async {
    try {
      final filtersData = await remoteDataSource.getDocumentFilter();
      return right(filtersData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Retrieves general documents with optional filtering parameters
  @override
  Future<Either<Failure, DocumentListEntity>> getGeneralDocuments({
    int page = 1,
    String? department,
    String? documentType,
    String? keyword,
  }) async {
    try {
      final documents = await remoteDataSource.getGeneralDocuments(
        page: page,
        department: department,
        docType: documentType,
        keyword: keyword,
      );
      return right(documents.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Retrieves faculty-specific documents with optional filtering parameters
  @override
  Future<Either<Failure, DocumentListEntity>> getFacultyDocuments({
    int page = 1,
    String? documentType,
    String? keyword,
    String? faculty,
  }) async {
    try {
      final documentsData = await remoteDataSource.getFacultyDocuments(
        page: page,
        docType: documentType,
        keyword: keyword,
        faculty: faculty,
      );
      return right(documentsData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Retrieves the PDF bytes of a specific document by its ID
  @override
  Future<Either<Failure, PDFBytes>> viewDocument({
    required String documentId,
  }) async {
    try {
      final pdfBytesData = await remoteDataSource.viewDocument(
        documentId: documentId,
      );
      return right(pdfBytesData.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Uploads a new PDF document with associated metadata
  @override
  Future<Either<Failure, void>> uploadPDFDocument({
    required File file,
    required String docType,
    String? department,
    String? faculty,
    required String fileUrl,
  }) async {
    try {
      await remoteDataSource.uploadPDFDocument(
        file: file,
        docType: docType,
        department: department,
        faculty: faculty,
        fileUrl: fileUrl,
      );
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Updates the basic information of an existing document
  @override
  Future<Either<Failure, void>> updateDocumentBasicInfo({
    required String documentId,
    String? title,
    String? documentType,
    String? department,
    String? faculty,
    String? fileUrl,
  }) async {
    try {
      final result = await remoteDataSource.updateDocumentBasicInfo(
        documentId: documentId,
        title: title,
        docType: documentType,
        department: department,
        faculty: faculty,
        fileUrl: fileUrl,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Deletes a document by its ID
  @override
  Future<Either<Failure, void>> deleteDocument({
    required String documentId,
  }) async {
    try {
      final result = await remoteDataSource.deleteDocument(
        documentId: documentId,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
