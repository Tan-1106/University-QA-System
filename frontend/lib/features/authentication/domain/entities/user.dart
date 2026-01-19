class UserEntity {
  final String id;
  final String sub;
  final String name;
  final String email;
  final String imageUrl;
  final String role;
  final String faculty;
  final bool banned;

  UserEntity({
    required this.id,
    required this.sub,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.role,
    required this.faculty,
    required this.banned,
  });

  factory UserEntity.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = (json['user'] as Map).cast<String, dynamic>();

    return UserEntity(
      id: user['_id'] as String,
      sub: user['sub'] as String,
      name: user['name'] as String,
      email: user['email'] as String,
      imageUrl: user['image'] as String,
      role: user['role'] as String,
      faculty: user['faculty'] as String,
      banned: user['banned'] as bool,
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      sub: json['sub'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      imageUrl: json['imageUrl'] as String,
      role: json['role'] as String,
      faculty: json['faculty'] as String,
      banned: json['banned'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sub': sub,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'role': role,
      'faculty': faculty,
      'banned': banned,
    };
  }

  @override
  String toString() {
    return 'UserResponse{id: $id, sub: $sub, name: $name, email: $email, imageUrl: $imageUrl, role: $role, faculty: $faculty, banned: $banned}';
  }
}
