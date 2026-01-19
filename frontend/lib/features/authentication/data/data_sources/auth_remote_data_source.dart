import 'package:dio/dio.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/features/authentication/data/models/current_user.dart';
import 'package:university_qa_system/features/authentication/data/models/tokens.dart';
import 'package:university_qa_system/features/authentication/data/models/elit_authenticated_details.dart';

abstract interface class AuthRemoteDataSource {
  // Sign up with system account
  Future<void> signUpSystemAccount({
    required String name,
    required String email,
    required String studentId,
    required String faculty,
    required String password,
  });

  // Sign in with system account
  Future<TokensModel> signInWithSystemAccount({
    required String email,
    required String password,
  });

  // Sign in with ELIT
  Future<ELITAuthenticatedDetailsModel> signInWithELIT({
    required String authCode,
  });

  // Get current user information
  Future<CurrentUserModel> getUserInformation();

  // Sign out (revoke tokens)
  Future<void> signOut({
    required String refreshToken,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  // Sign up with system account
  @override
  Future<void> signUpSystemAccount({
    required String name,
    required String email,
    required String studentId,
    required String faculty,
    required String password,
  }) async {
    try {
      await _dio.post(
        '/api/auth/register',
        data: {
          'name': name,
          'email': email,
          'student_id': studentId,
          'faculty': faculty,
          'password': password,
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

  // Sign in with system account
  @override
  Future<TokensModel> signInWithSystemAccount({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<TokensModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => TokensModel.fromJson(json as Map<String, dynamic>),
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

  // Sign in with ELIT
  @override
  Future<ELITAuthenticatedDetailsModel> signInWithELIT({
    required String authCode,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/verify',
        data: {
          'code': authCode,
        },
      );

      final apiResponse = ApiResponse<ELITAuthenticatedDetailsModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ELITAuthenticatedDetailsModel.fromJson(json as Map<String, dynamic>),
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

  // Get current user information
  @override
  Future<CurrentUserModel> getUserInformation() async {
    try {
      final response = await _dio.get('/api/auth/me');

      final apiResponse = ApiResponse<CurrentUserModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CurrentUserModel.fromJson(json as Map<String, dynamic>),
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

  // Sign out (revoke tokens)
  @override
  Future<void> signOut({
    required String refreshToken,
  }) async {
    try {
      await _dio.post(
        '/api/users/logout',
        data: {
          'refresh_token': refreshToken,
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
}
