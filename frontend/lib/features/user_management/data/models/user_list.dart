import 'package:university_qa_system/features/user_management/data/models/user.dart';
import 'package:university_qa_system/features/user_management/domain/entities/user_list.dart';

class UserListModel {
  final List<UserModel> users;
  final int total;
  final int totalPages;
  final int currentPage;

  UserListModel({
    required this.users,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    var usersJson = json['users'] as List<dynamic>;
    List<UserModel> usersList = usersJson
        .map(
          (userJson) => UserModel(
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

    return UserListModel(
      users: usersList,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }

  UserListEntity toEntity() {
    return UserListEntity(
      users: users.map((userModel) => userModel.toEntity()).toList(),
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