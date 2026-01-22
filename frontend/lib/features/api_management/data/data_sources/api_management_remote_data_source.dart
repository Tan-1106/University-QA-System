import 'package:dio/dio.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/features/api_management/data/models/api_key.dart';
import 'package:university_qa_system/features/api_management/data/models/api_keys_data.dart';

abstract interface class APIManagementRemoteDataSource {
  // Add a new API key
  Future<String> addAPIKey({
    required String name,
    String? description,
    required String provider,
    required String apiKey,
  });

  // Get a paginated list of API keys with optional filtering by provider and keyword
  Future<APIKeyListModel> getAPIKeys({
    required int page,
    String? provider,
    String? keyword,
  });

  // Get API key details by ID
  Future<APIKeyModel> getKeyById({
    required String id,
  });

  // Get available models for a given API key and provider
  Future<List<String>> getKeyModels({
    required String key,
    required String provider,
  });

  // Add a model to an existing API key
  Future<void> addKeyModel({
    required String id,
    required String model,
  });

  // Toggle the usage status of an API key
  Future<void> toggleUsingKey({
    required String id,
  });

  // Delete an API key by ID
  Future<void> deleteAPIKey({
    required String id,
  });
}

class APIManagementRemoteDataSourceImpl implements APIManagementRemoteDataSource {
  final Dio _dio;

  APIManagementRemoteDataSourceImpl(this._dio);

  // Add a new API key
  @override
  Future<String> addAPIKey({
    required String name,
    String? description,
    required String provider,
    required String apiKey,
  }) async {
    try {
      final response = await _dio.post(
        '/api/model/api-keys',
        data: {
          'name': name,
          if (description != null) 'description': description,
          'provider': provider,
          'api_key': apiKey,
        },
      );

      final details = response.data['details'] as Map<String, dynamic>;
      return details['_id'] as String;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Get a paginated list of API keys with optional filtering by provider and keyword
  @override
  Future<APIKeyListModel> getAPIKeys({
    int page = 1,
    String? provider,
    String? keyword,
  }) async {
    try {
      final response = await _dio.get(
        '/api/model/api-keys',
        queryParameters: {
          'page': page,
          if (provider != null) 'provider': provider,
          if (keyword != null) 'keyword': keyword,
        },
      );

      final apiResponse = ApiResponse<APIKeyListModel>.fromJson(
        response.data as Map<String, dynamic>,
            (data) => APIKeyListModel.fromJson(data as Map<String, dynamic>),
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

  // Get API key details by ID
  @override
  Future<APIKeyModel> getKeyById({required String id}) async {
    try {
      final response = await _dio.get(
        '/model/api-keys/$id',
      );

      final apiResponse = ApiResponse<APIKeyModel>.fromJson(
        response.data as Map<String, dynamic>,
            (data) => APIKeyModel.fromJson(data as Map<String, dynamic>),
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

  // Get available models for a given API key and provider
  @override
  Future<List<String>> getKeyModels({
    required String key,
    required String provider,
  }) async {
    try {
      final response = await _dio.post(
        '/api/model/available-models',
        data: {
          'api_key': key,
          'provider': provider,
        },
      );

      final details = response.data['details'] as Map<String, dynamic>;
      final models = details['models'] as List;
      return models.map((model) => model.toString()).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Add a model to an existing API key
  @override
  Future<void> addKeyModel({
    required String id,
    required String model,
  }) async {
    try {
      await _dio.post(
        '/api/model/api-keys/$id/add-model',
        data: {
          'using_model': model,
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

  // Toggle the usage status of an API key
  @override
  Future<void> toggleUsingKey({
    required String id,
  }) async {
    try {
      await _dio.post(
        '/api/model/api-keys/$id/toggle-usage',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Delete an API key by ID
  @override
  Future<void> deleteAPIKey({
    required String id,
  }) async {
    try {
      await _dio.delete(
        '/api/model/api-keys/$id',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }
}
