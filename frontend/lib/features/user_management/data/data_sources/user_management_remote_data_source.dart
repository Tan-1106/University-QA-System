import 'package:dio/dio.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/user_management/data/models/users_data.dart';

abstract interface class UserManagementRemoteDataSource {
  Future<UsersData> fetchAllUsers({
    int page = 1,
    String? role,
    String? faculty,
    bool? banned,
    String? keyword,
});

  Future<List<String>> fetchAllRoles();

  Future<List<String>> fetchAllFaculties();

  Future<bool> assignRole(String userId, String roleToAssign, String? faculty);

  Future<bool> changeUserBanStatus(String userId, bool currentBanStatus);
}

class UserManagementDataSourceImpl implements UserManagementRemoteDataSource {
  final Dio _dio;

  UserManagementDataSourceImpl(this._dio);

  @override
  Future<UsersData> fetchAllUsers({
    int page = 1,
    String? role,
    String? faculty,
    bool? banned,
    String? keyword,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page.toString(),
        if (banned != null) 'banned': banned.toString(),
        if (role != null) 'role': role,
        if (faculty != null) 'faculty': faculty,
        if (keyword != null) 'keyword': keyword,
      };

      final response = await _dio.get(
        '/api/users',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<UsersData>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => UsersData.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.details != null) {
          return apiResponse.details!;
        } else {
          throw const ServerException('No user data found');
        }
      } else {
        throw const ServerException('Failed to retrieve users');
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
  Future<List<String>> fetchAllRoles() async {
    try {
      final response = await _dio.get('/api/users/roles');
      if (response.statusCode == 200 && response.data != null) {
        final details = response.data['details'] as Map<String, dynamic>;
        final roles = details['roles'] as List;
        return roles.map((role) => role.toString()).toList();
      } else {
        throw const ServerException('Failed to retrieve roles');
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
        final details = response.data['details'] as Map<String, dynamic>;
        final faculties = details['faculties'] as List;
        return faculties.map((faculty) => faculty.toString()).toList();
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
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> assignRole(String userId, String roleToAssign, String? faculty) async {
    try {
      if (roleToAssign == 'Admin') {
        final response = await _dio.post(
          '/api/users/$userId/assign-admin',
        );
        if (response.statusCode != 200) {
          throw const ServerException('Failed to assign Admin role');
        }
      }

      if (roleToAssign == 'Student' && faculty != null) {
        final response = await _dio.post(
          '/api/users/$userId/assign-student',
          data: {'faculty': faculty},
        );
        if (response.statusCode != 200) {
          throw const ServerException('Failed to assign Student role');
        }
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


  @override
  Future<bool> changeUserBanStatus(String userId, bool currentBanStatus) async {
    try {
      final endpoint = currentBanStatus ? 'unban' : 'ban';
      final response = await _dio.patch(
        '/api/users/$userId/$endpoint',
      );
      if (response.statusCode != 200) {
        throw ServerException('Failed to ${currentBanStatus ? 'unban' : 'ban'} user');
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
