import 'package:dio/dio.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/core/utils/app_bloc_observer.dart';
import 'package:university_qa_system/features/authentication/data/models/current_user.dart';
import 'package:university_qa_system/features/authentication/data/models/user_details.dart';

abstract interface class AuthRemoteDataSource {
  Future<bool> registerSystemAccount(
    String name,
    String email,
    String studentId,
    String faculty,
    String password,
  );

  Future<Tokens> signInWithSystemAccount(String email, String password);

  Future<UserDetails> signInWithELIT(String authCode);

  Future<CurrentUser> getUserInformation();

  Future<bool> signOut(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<bool> registerSystemAccount(
    String name,
    String email,
    String studentId,
    String faculty,
    String password,
  ) async {
    try {
      logger.i('Attempting to register user with email: $email');
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'name': name,
          'email': email,
          'student_id': studentId,
          'faculty': faculty,
          'password': password,
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw const ServerException('Failed to register user');
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
  Future<Tokens> signInWithSystemAccount(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<Tokens>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => Tokens.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.details != null) {
          return apiResponse.details!;
        } else {
          throw const ServerException('Tokens are missing in the response');
        }
      } else {
        throw const ServerException('Failed to sign in');
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
          throw const ServerException('User details are missing in the response');
        }
      } else {
        throw const ServerException('Failed to retrieve user information');
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
          throw const ServerException('User details are missing in the response');
        }
      } else {
        throw const ServerException('Failed to retrieve user information');
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
  Future<bool> signOut(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/api/users/logout',
        data: {
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode != 200) {
        throw const ServerException('Failed to sign out');
      }

      return true;
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
