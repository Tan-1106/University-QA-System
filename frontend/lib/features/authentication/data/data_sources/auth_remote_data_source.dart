import 'package:dio/dio.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/features/authentication/data/models/current_user.dart';
import 'package:university_qa_system/features/authentication/data/models/user_details.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserDetails> signInWithELIT(String authCode);

  Future<CurrentUser> getUserInformation();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<UserDetails> signInWithELIT(String authCode) async {
    try {
      final response = await _dio.post(
        '/api/auth/verify',
        data: {
          'code': authCode,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<UserDetails>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => UserDetails.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.details != null) {
          return apiResponse.details!;
        } else {
          throw ServerException('User details are missing in the response');
        }
      } else {
        throw ServerException('Failed to retrieve user information');
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
  Future<CurrentUser> getUserInformation() async {
    try {
      final response = await _dio.get('/api/auth/me');

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<CurrentUser>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => CurrentUser.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.details != null) {
          return apiResponse.details!;
        } else {
          throw ServerException('User details are missing in the response');
        }
      } else {
        throw ServerException('Failed to retrieve user information');
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
