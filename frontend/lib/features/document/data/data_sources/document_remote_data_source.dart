import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/core/utils/app_bloc_observer.dart';
import 'package:university_qa_system/features/document/data/models/filters_data.dart';
import 'package:university_qa_system/features/document/data/models/documents_data.dart';
import 'package:university_qa_system/features/document/data/models/pdf_bytes_data.dart';

abstract interface class DocumentRemoteDataSource {
  Future<FiltersData> fetchDocumentFilters();

  Future<List<String>> fetchAllFaculties();

  Future<DocumentsData> fetchGeneralDocuments({
    int page = 1,
    String? docType,
    String? department,
    String? keyword,
  });

  Future<DocumentsData> fetchFacultyDocuments({
    int page = 1,
    String? docType,
    String? keyword,
    String? faculty,
  });

  Future<PDFBytesData> viewDocument(String documentId);

  Future<bool> deleteDocument(String documentId);
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final Dio _dio;

  DocumentRemoteDataSourceImpl(this._dio);

  @override
  Future<FiltersData> fetchDocumentFilters() async {
    try {
      final departments = await _dio.get('/api/documents/departments');
      final documentTypes = await _dio.get('/api/documents/doc-types');

      if (departments.statusCode == 200 && documentTypes.statusCode == 200 && departments.data != null && documentTypes.data != null) {
        final departmentsResponse = ApiResponse<List<String>>.fromJson(
          departments.data as Map<String, dynamic>,
          (json) {
            return (json as List).map((e) => e as String).toList();
          },
        );

        final documentTypesResponse = ApiResponse<List<String>>.fromJson(
          documentTypes.data as Map<String, dynamic>,
          (json) {
            return (json as List).map((e) => e as String).toList();
          },
        );

        return FiltersData(
          existingDepartments: departmentsResponse.details ?? [],
          existingDocumentTypes: documentTypesResponse.details ?? [],
        );
      } else {
        throw const ServerException('Failed to retrieve document filters');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> fetchAllFaculties() async {
    try {
      final response = await _dio.get('/api/users/faculties');
      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<List<String>>.fromJson(
          response.data as Map<String, dynamic>,
          (json) {
            if (json is Map<String, dynamic> && json.containsKey('faculties')) {
              final faculties = List<String>.from(json['faculties'] as List);
              return faculties;
            }
            throw const ServerException('Invalid faculties data structure');
          },
        );
        return apiResponse.details ?? [];
      } else {
        throw const ServerException('Failed to retrieve faculties');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    } catch (e) {
      logger.e('Exception while fetching faculties: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DocumentsData> fetchGeneralDocuments({
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

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<DocumentsData>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => DocumentsData.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.details != null) {
          return apiResponse.details!;
        } else {
          throw const ServerException('Documents data is missing in the response');
        }
      } else {
        throw const ServerException('Failed to retrieve documents data');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DocumentsData> fetchFacultyDocuments({
    int page = 1,
    String? docType,
    String? keyword,
    String? faculty,
  }) async {
    try {
      logger.i(
        'Fetching faculty documents with page: $page, docType: $docType, keyword: $keyword, faculty: $faculty',
      );

      final response = await _dio.get(
        '/api/documents/faculty',
        queryParameters: {
          'page': page,
          if (keyword != null) 'keyword': keyword,
          if (docType != null) 'doc_type': docType,
          if (faculty != null) 'faculty': faculty,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<DocumentsData>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => DocumentsData.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.details != null) {
          return apiResponse.details!;
        } else {
          throw const ServerException('Documents data is missing in the response');
        }
      } else {
        throw const ServerException('Failed to retrieve documents data');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PDFBytesData> viewDocument(String documentId) async {
    try {
      final response = await _dio.get(
        '/api/documents/view/$documentId',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data);
        return PDFBytesData(bytes);
      } else {
        throw const ServerException('Failed to retrieve document bytes');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteDocument(String documentId) async {
    try {
      final response = await _dio.delete('/api/documents/$documentId');
      if (response.statusCode == 200) {
        return true;
      } else {
        throw const ServerException('Failed to delete document');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
