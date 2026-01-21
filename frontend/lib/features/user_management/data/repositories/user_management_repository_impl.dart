import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/user_management/data/data_sources/user_management_remote_data_source.dart';
import 'package:university_qa_system/features/user_management/domain/entities/user_list.dart';
import 'package:university_qa_system/features/user_management/domain/repositories/user_management_repository.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementRemoteDataSource remoteDataSource;

  const UserManagementRepositoryImpl(this.remoteDataSource);

  // Get all available roles
  @override
  Future<Either<Failure, List<String>>> getAllRoles() async {
    try {
      final result = await remoteDataSource.getAllRoles();
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Get all available faculties
  @override
  Future<Either<Failure, List<String>>> getAllFaculties() async {
    try {
      final result = await remoteDataSource.getAllFaculties();
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Get all users with optional filters
  @override
  Future<Either<Failure, UserListEntity>> getAllUsers({
    int page = 1,
    String? role,
    String? faculty,
    bool? banned,
    String? keyword,
  }) async {
    try {
      final result = await remoteDataSource.getAllUsers(
        page: page,
        role: role,
        faculty: faculty,
        banned: banned,
        keyword: keyword,
      );
      return right(result.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Assign role to a user
  @override
  Future<Either<Failure, void>> assignRole({
    required String userId,
    required String roleToAssign,
    required String? faculty,
  }) async {
    try {
      final result = await remoteDataSource.assignRole(
        userId: userId,
        roleToAssign: roleToAssign,
        faculty: faculty,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // Change user ban status
  @override
  Future<Either<Failure, void>> changeUserBanStatus({
    required String userId,
    required bool currentBanStatus,
  }) async {
    try {
      final result = await remoteDataSource.changeUserBanStatus(
        userId: userId,
        currentBanStatus: currentBanStatus,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
