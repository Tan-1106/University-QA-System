import 'package:university_qa_system/features/user_management/domain/entities/user.dart';

class UserListEntity {
  final List<UserEntity> users;
  final int total;
  final int totalPages;
  final int currentPage;

  UserListEntity({
    required this.users,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  String toString() {
    return 'UserListEntity(users: $users, total: $total, totalPages: $totalPages, currentPage: $currentPage)';
  }
}