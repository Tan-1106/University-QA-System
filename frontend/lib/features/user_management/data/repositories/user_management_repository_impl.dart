import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/user_management/data/data_sources/user_management_remote_data_source.dart';
import 'package:university_qa_system/features/user_management/domain/entities/users.dart';
import 'package:university_qa_system/features/user_management/domain/repositories/user_management_repository.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementRemoteDataSource remoteDataSource;

  const UserManagementRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Users>> fetchAllUsers({
    int page = 1,
    String? role,
    String? faculty,
    bool? banned,
    String? keyword,
  }) async {
    try {
      final result = await remoteDataSource.fetchAllUsers(
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

  @override
  Future<Either<Failure, List<String>>> fetchAllRoles() async {
    try {
      final result = await remoteDataSource.fetchAllRoles();
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> fetchAllFaculties() async {
    try {
      final result = await remoteDataSource.fetchAllFaculties();
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> assignRole(String userId, String roleToAssign, String? faculty) async {
    try {
      final result = await remoteDataSource.assignRole(userId, roleToAssign, faculty);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> changeUserBanStatus(String userId, bool currentBanStatus) async {
    try {
      final result = await remoteDataSource.changeUserBanStatus(userId, currentBanStatus);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}