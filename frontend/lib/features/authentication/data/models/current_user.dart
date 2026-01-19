import 'package:university_qa_system/features/authentication/data/models/tokens.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';

class CurrentUserModel {
  final String id;
  final String sub;
  final String name;
  final String email;
  final String imageUrl;
  final String role;
  final String? faculty;
  final bool banned;

  CurrentUserModel({
    required this.id,
    required this.sub,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.role,
    required this.faculty,
    required this.banned,
  });

  factory CurrentUserModel.fromJson(Map<String, dynamic> json) {
    return CurrentUserModel(
      id: json['_id'] as String,
      sub: json['sub'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
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
      email: email,
      imageUrl: imageUrl,
      role: role,
      faculty: faculty ?? '',
      banned: banned,
    );
  }

  @override
  String toString() {
    return 'CurrentUser{id: $id, sub: $sub, name: $name, email: $email, imageUrl: $imageUrl, role: $role, faculty: $faculty, banned: $banned}';
  }
}
