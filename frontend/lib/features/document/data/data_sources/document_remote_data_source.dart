import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/features/document/data/models/filters_data.dart';
import 'package:university_qa_system/features/document/data/models/document_list.dart';
import 'package:university_qa_system/features/document/data/models/pdf_bytes_data.dart';

abstract interface class DocumentRemoteDataSource {
  // Retrieves document filters such as departments, document types, and faculties
  Future<FiltersData> getDocumentFilter();

  // Retrieves general documents with optional filtering parameters
  Future<DocumentListModel> getGeneralDocuments({
    int page = 1,
    String? docType,
    String? department,
    String? keyword,
  });

  // Retrieves faculty-specific documents with optional filtering parameters
  Future<DocumentListModel> getFacultyDocuments({
    int page = 1,
    String? docType,
    String? keyword,
    String? faculty,
  });

  // Retrieves the PDF bytes of a specific document by its ID
  Future<PDFBytesData> viewDocument({
    required String documentId,
  });

  // Uploads a PDF document with associated metadata
  Future<void> uploadPDFDocument({
    required File file,
    required String docType,
    String? department,
    String? faculty,
    required String fileUrl,
  });

  // Updates the basic information of a document
  Future<void> updateDocumentBasicInfo({
    required String documentId,
    String? title,
    String? docType,
    String? department,
    String? faculty,
    String? fileUrl,
  });

  // Deletes a document by its ID
  Future<void> deleteDocument({
    required String documentId,
  });
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final Dio _dio;

  DocumentRemoteDataSourceImpl(this._dio);

  // Fetches document filters from the server
  @override
  Future<FiltersData> getDocumentFilter() async {
    try {
      final departments = await _dio.get(
        '/api/documents/departments',
      );
      final documentTypes = await _dio.get(
        '/api/documents/doc-types',
      );
      final faculties = await _dio.get(
        '/api/users/faculties',
      );

      final departmentsResponse = ApiResponse<List<String>>.fromJson(
        departments.data as Map<String, dynamic>,
        (json) => (json as List).map((e) => e as String).toList(),
      );

      final documentTypesResponse = ApiResponse<List<String>>.fromJson(
        documentTypes.data as Map<String, dynamic>,
        (json) => (json as List).map((e) => e as String).toList(),
      );

      final facultiesResponse = ApiResponse<List<String>>.fromJson(
        faculties.data as Map<String, dynamic>,
        (json) {
          if (json is Map<String, dynamic> && json.containsKey('faculties')) {
            return List<String>.from(json['faculties'] as List);
          }
          return <String>[];
        },
      );

      return FiltersData(
        existingDepartments: departmentsResponse.details ?? [],
        existingDocumentTypes: documentTypesResponse.details ?? [],
        existingFaculties: facultiesResponse.details ?? [],
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Fetches general documents with optional filters
  @override
  Future<DocumentListModel> getGeneralDocuments({
    int page = 1,
    String? docType,
    String? department,
    String? keyword,
  }) async {
    try {
      final response = await _dio.get(
        '/api/documents/general',
        queryParameters: {
          'page': page,
          if (keyword != null) 'keyword': keyword,
          if (docType != null) 'doc_type': docType,
          if (department != null) 'department': department,
        },
      );

      final apiResponse = ApiResponse<DocumentListModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => DocumentListModel.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.details!;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Fetches faculty-specific documents with optional filters
  @override
  Future<DocumentListModel> getFacultyDocuments({
    int page = 1,
    String? docType,
    String? keyword,
    String? faculty,
  }) async {
    try {
      final response = await _dio.get(
        '/api/documents/faculty',
        queryParameters: {
          'page': page,
          if (keyword != null) 'keyword': keyword,
          if (docType != null) 'doc_type': docType,
          if (faculty != null) 'faculty': faculty,
        },
      );

      final apiResponse = ApiResponse<DocumentListModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => DocumentListModel.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.details!;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Retrieves the PDF bytes of a document by its ID
  @override
  Future<PDFBytesData> viewDocument({
    required String documentId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/documents/view/$documentId',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      final bytes = Uint8List.fromList(response.data);
      return PDFBytesData(bytes);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Uploads a PDF document with metadata to the server
  @override
  Future<void> uploadPDFDocument({
    required File file,
    required String docType,
    String? department,
    String? faculty,
    required String fileUrl,
  }) async {
    try {
      String fileName = file.path.split('/').last;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType('application', 'pdf'),
        ),
        'doc_type': docType,
        if (department != null) 'department': department,
        if (faculty != null) 'faculty': faculty,
        'file_url': fileUrl,
      });

      await _dio.post(
        '/api/documents/upload',
        data: formData,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Updates the basic information of a document
  @override
  Future<void> updateDocumentBasicInfo({
    required String documentId,
    String? title,
    String? docType,
    String? department,
    String? faculty,
    String? fileUrl,
  }) async {
    try {
      await _dio.patch(
        '/api/documents/$documentId',
        data: {
          if (title != null) 'file_name': title,
          if (docType != null) 'doc_type': docType,
          if (department != null) 'department': department,
          if (faculty != null) 'faculty': faculty,
          if (fileUrl != null) 'file_url': fileUrl,
        },
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Deletes a document by its ID
  @override
  Future<void> deleteDocument({
    required String documentId,
  }) async {
    try {
      await _dio.delete('/api/documents/$documentId');
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }
}
