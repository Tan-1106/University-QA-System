import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/user_management/domain/entities/user_list.dart';

abstract interface class UserManagementRepository {
  // Get all available roles
  Future<Either<Failure, List<String>>> getAllRoles();

  // Get all available faculties
  Future<Either<Failure, List<String>>> getAllFaculties();

  // Get all users with optional filters
  Future<Either<Failure, UserListEntity>> getAllUsers({
    int page = 1,
    String? role,
    String? faculty,
    bool? banned,
    String? keyword,
  });

  // Assign role to a user
  Future<Either<Failure, void>> assignRole({
    required String userId,
    required String roleToAssign,
    required String? faculty,
  });

  // Change user ban status
  Future<Either<Failure, void>> changeUserBanStatus({
    required String userId,
    required bool currentBanStatus,
  });
}
