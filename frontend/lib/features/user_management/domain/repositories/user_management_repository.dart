import 'package:fpdart/fpdart.dart';
import 'package:university_qa_system/core/error/failures.dart';
import 'package:university_qa_system/features/user_management/domain/entities/users.dart';

abstract interface class UserManagementRepository {
  Future<Either<Failure, Users>> fetchAllUsers({
    int page = 1,
    String? role,
    String? faculty,
    bool? banned,
    String? keyword,
  });

  Future<Either<Failure, List<String>>> fetchAllRoles();

  Future<Either<Failure, List<String>>> fetchAllFaculties();

  Future<Either<Failure, bool>> assignRole(String userId, String roleToAssign, String? faculty);

  Future<Either<Failure, bool>> changeUserBanStatus(String userId, bool currentBanStatus);
}
