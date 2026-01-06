import 'package:university_qa_system/features/user_management/domain/entities/users.dart';

class UsersData {
  final List<User> users;
  final int total;
  final int totalPages;
  final int currentPage;

  UsersData({
    required this.users,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory UsersData.fromJson(Map<String, dynamic> json) {
    var usersJson = json['users'] as List<dynamic>;
    List<User> usersList = usersJson
        .map(
          (userJson) => User(
            id: userJson['_id'] as String,
            sub: userJson['sub'] as String,
            name: userJson['name'] as String,
            imageUrl: userJson['image'] as String,
            role: userJson['role'] as String,
            faculty: userJson['faculty'] as String?,
            banned: userJson['banned'] as bool,
          ),
        )
        .toList();

    return UsersData(
      users: usersList,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }

  Users toEntity() {
    return Users(
      users: users,
      total: total,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  @override
  String toString() {
    return 'UserData{total: $total, totalPages: $totalPages, currentPage: $currentPage, users: $users}';
  }
}