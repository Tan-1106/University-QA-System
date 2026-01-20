import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/document/domain/entities/filters.dart';
import 'package:university_qa_system/features/document/domain/entities/pdf_bytes.dart';
import 'package:university_qa_system/features/document/domain/entities/document_list.dart';

abstract interface class DocumentRepository {
  // Retrieves document filters such as departments, document types, and faculties
  Future<Either<Failure, FiltersEntity>> getDocumentFilter();

  // Retrieves general documents with optional filtering parameters
  Future<Either<Failure, DocumentListEntity>> getGeneralDocuments({
    int page = 1,
    String? department,
    String? documentType,
    String? keyword,
  });

  // Retrieves faculty-specific documents with optional filtering parameters
  Future<Either<Failure, DocumentListEntity>> getFacultyDocuments({
    int page = 1,
    String? documentType,
    String? keyword,
    String? faculty,
  });

  // Retrieves the PDF bytes of a specific document by its ID
  Future<Either<Failure, PDFBytes>> viewDocument({
    required String documentId,
  });

  // Uploads a PDF document with associated metadata
  Future<Either<Failure, void>> uploadPDFDocument({
    required File file,
    required String docType,
    String? department,
    String? faculty,
    required String fileUrl,
  });

  // Updates the basic information of a document
  Future<Either<Failure, void>> updateDocumentBasicInfo({
    required String documentId,
    String? title,
    String? documentType,
    String? department,
    String? faculty,
    String? fileUrl,
  });

  // Deletes a document by its ID
  Future<Either<Failure, void>> deleteDocument({
    required String documentId,
  });
}
