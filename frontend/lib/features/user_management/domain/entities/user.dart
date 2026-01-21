class UserEntity {
  final String id;
  final String sub;
  final String name;
  final String imageUrl;
  final String role;
  final String? faculty;
  final bool banned;

  UserEntity({
    required this.id,
    required this.sub,
    required this.name,
    required this.imageUrl,
    required this.role,
    this.faculty,
    required this.banned,
  });

  @override
  String toString() {
    return 'UserEntity(id: $id, sub: $sub, name: $name, imageUrl: $imageUrl, role: $role, faculty: $faculty, banned: $banned)';
  }
}