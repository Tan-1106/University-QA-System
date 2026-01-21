import 'package:dio/dio.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/user_management/data/models/user_list.dart';

abstract interface class UserManagementRemoteDataSource {
  // Get all available roles
  Future<List<String>> getAllRoles();

  // Get all available faculties
  Future<List<String>> getAllFaculties();

  // Get all users with optional filters
  Future<UserListModel> getAllUsers({
    int page = 1,
    String? role,
    String? faculty,
    bool? banned,
    String? keyword,
  });

  // Assign role to a user
  Future<void> assignRole({
    required String userId,
    required String roleToAssign,
    required String? faculty,
  });

  // Change user ban status
  Future<void> changeUserBanStatus({
    required String userId,
    required bool currentBanStatus,
  });
}

class UserManagementDataSourceImpl implements UserManagementRemoteDataSource {
  final Dio _dio;

  UserManagementDataSourceImpl(this._dio);

  // Get all available roles
  @override
  Future<List<String>> getAllRoles() async {
    try {
      final response = await _dio.get('/api/users/roles');
      final details = response.data['details'] as Map<String, dynamic>;
      final roles = details['roles'] as List;
      return roles.map((role) => role.toString()).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Get all available faculties
  @override
  Future<List<String>> getAllFaculties() async {
    try {
      final response = await _dio.get('/api/users/faculties');
      final details = response.data['details'] as Map<String, dynamic>;
      final faculties = details['faculties'] as List;
      return faculties.map((faculty) => faculty.toString()).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Get all users with optional filters
  @override
  Future<UserListModel> getAllUsers({
    int page = 1,
    String? role,
    String? faculty,
    bool? banned,
    String? keyword,
  }) async {
    try {
      final response = await _dio.get(
        '/api/users',
        queryParameters: {
          'page': page.toString(),
          if (banned != null) 'banned': banned.toString(),
          if (role != null) 'role': role,
          if (faculty != null) 'faculty': faculty,
          if (keyword != null) 'keyword': keyword,
        },
      );

      final apiResponse = ApiResponse<UserListModel>.fromJson(
        response.data as Map<String, dynamic>,
            (json) => UserListModel.fromJson(json as Map<String, dynamic>),
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

  // Assign role to a user
  @override
  Future<void> assignRole({
    required String userId,
    required String roleToAssign,
    required String? faculty,
  }) async {
    try {
      if (roleToAssign == 'Admin') {
        await _dio.post(
          '/api/users/$userId/assign-admin',
        );
      }
      else if (roleToAssign == 'Student' && faculty != null) {
        await _dio.post(
          '/api/users/$userId/assign-student',
          data: {'faculty': faculty},
        );
      } else {
        throw const ServerException('Invalid role or missing faculty');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Change user ban status
  @override
  Future<void> changeUserBanStatus({
    required String userId,
    required bool currentBanStatus,
  }) async {
    try {
      final endpoint = currentBanStatus ? 'unban' : 'ban';
      await _dio.patch(
        '/api/users/$userId/$endpoint',
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
