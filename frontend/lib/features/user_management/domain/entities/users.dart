class Users {
  final List<User> users;
  final int total;
  final int totalPages;
  final int currentPage;

  Users({
    required this.users,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });
}

class User {
  final String id;
  final String sub;
  final String name;
  final String imageUrl;
  final String role;
  final String? faculty;
  final bool banned;

  User({
    required this.id,
    required this.sub,
    required this.name,
    required this.imageUrl,
    required this.role,
    this.faculty,
    required this.banned,
  });
}