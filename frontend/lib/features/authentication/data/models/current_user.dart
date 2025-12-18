import '../../domain/entities/user.dart';

class CurrentUser {
  final String id;
  final String sub;
  final String name;
  final String email;
  final String imageUrl;
  final String role;
  final String? faculty;
  final bool isFacultyManager;
  final bool banned;

  CurrentUser({
    required this.id,
    required this.sub,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.role,
    required this.faculty,
    required this.isFacultyManager,
    required this.banned,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['_id'] as String,
      sub: json['sub'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      imageUrl: json['image'] as String,
      role: json['role'] as String,
      faculty: json['faculty'] as String?,
      isFacultyManager: json['is_faculty_manager'] as bool,
      banned: json['banned'] as bool,
    );
  }

  User toEntity() {
    return User(
      id: id,
      sub: sub,
      name: name,
      email: email,
      imageUrl: imageUrl,
      role: role,
      faculty: faculty ?? '',
      isFacultyManager: isFacultyManager,
      banned: banned,
    );
  }

  @override
  String toString() {
    return 'CurrentUser{id: $id, sub: $sub, name: $name, email: $email, imageUrl: $imageUrl, role: $role, faculty: $faculty, isFacultyManager: $isFacultyManager, banned: $banned}';
  }
}