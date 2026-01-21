import 'package:university_qa_system/features/user_management/domain/entities/user.dart';

class UserModel {
  final String id;
  final String sub;
  final String name;
  final String imageUrl;
  final String role;
  final String? faculty;
  final bool banned;

  UserModel({
    required this.id,
    required this.sub,
    required this.name,
    required this.imageUrl,
    required this.role,
    this.faculty,
    required this.banned,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      sub: json['sub'] as String,
      name: json['name'] as String,
      imageUrl: json['image'] as String,
      role: json['role'] as String,
      faculty: json['faculty'] as String?,
      banned: json['banned'] as bool,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      sub: sub,
      name: name,
      imageUrl: imageUrl,
      role: role,
      faculty: faculty,
      banned: banned,
    );
  }
}