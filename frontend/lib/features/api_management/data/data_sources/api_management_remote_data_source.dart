import 'package:dio/dio.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/features/api_management/data/models/api_keys_data.dart';

abstract interface class APIManagementRemoteDataSource {
  Future<APIKeysData> fetchAPIKeys({
    required int page,
    String? provider,
    String? keyword,
  });

  Future<APIKeyData> getKeyById({
    required String id,
  });

  Future<String> addAPIKey({
    required String name,
    String? description,
    required String provider,
    required String apiKey,
  });

  Future<bool> deleteAPIKey({
    required String id,
  });

  Future<List<String>> getKeyModels({
    required String key,
    required String provider,
  });

  Future<bool> addKeyModel({
    required String id,
    required String model,
  });

  Future<bool> toggleUsingKey({
    required String id,
  });
}

class APIManagementRemoteDataSourceImpl implements APIManagementRemoteDataSource {
  final Dio _dio;

  APIManagementRemoteDataSourceImpl(this._dio);

  @override
  Future<APIKeysData> fetchAPIKeys({int page = 1, String? provider, String? keyword}) async {
    try {
      final response = await _dio.get(
        '/api/model/api-keys',
        queryParameters: {
          'page': page,
          if (provider != null) 'provider': provider,
          if (keyword != null) 'keyword': keyword,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<APIKeysData>.fromJson(
          response.data as Map<String, dynamic>,
          (data) => APIKeysData.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.details != null) {
          return apiResponse.details!;
        } else {
          throw const ServerException('No API keys data found');
        }
      } else {
        throw const ServerException('Failed to fetch API keys');
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
  Future<APIKeyData> getKeyById({required String id}) async {
    try {
      final response = await _dio.get(
        '/model/api-keys/$id',
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<APIKeyData>.fromJson(
          response.data as Map<String, dynamic>,
          (data) => APIKeyData.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.details != null) {
          return apiResponse.details!;
        } else {
          throw const ServerException('No API key data found');
        }
      } else {
        throw const ServerException('Failed to fetch API key');
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

      if (response.statusCode == 201 && response.data != null) {
        final details = response.data['details'] as Map<String, dynamic>;
        return details['_id'] as String;
      } else {
        throw const ServerException('Failed to add API key');
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
  Future<bool> deleteAPIKey({
    required String id,
  }) async {
    try {
      final response = await _dio.delete(
        '/api/model/api-keys/$id',
      );
      if (response.statusCode == 200 && response.data != null) {
        return true;
      } else {
        throw const ServerException('Failed to delete API key');
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

      if (response.statusCode == 200 && response.data != null) {
        final details = response.data['details'] as Map<String, dynamic>;
        final models = details['models'] as List;
        return models.map((model) => model.toString()).toList();
      } else {
        throw const ServerException('Failed to get key models');
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
  Future<bool> addKeyModel({
    required String id,
    required String model,
  }) async {
    try {
      final response = await _dio.post(
        '/api/model/api-keys/$id/add-model',
        data: {
          'using_model': model,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return true;
      } else {
        throw const ServerException('Failed to add key model');
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
  Future<bool> toggleUsingKey({
    required String id,
  }) async {
    try {
      final response = await _dio.post(
        '/api/model/api-keys/$id/toggle-usage',
      );

      if (response.statusCode == 200 && response.data != null) {
        return true;
      } else {
        throw const ServerException('Failed to toggle using key');
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
