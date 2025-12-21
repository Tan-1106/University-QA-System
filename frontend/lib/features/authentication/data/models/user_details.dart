import '../../domain/entities/user.dart';

class UserDetails {
  final String id;
  final String sub;
  final String name;
  final String email;
  final String imageUrl;
  final String role;
  final String? faculty;
  final bool banned;
  final Tokens tokens;

  UserDetails({
    required this.id,
    required this.sub,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.role,
    required this.faculty,
    required this.banned,
    required this.tokens,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = (json['user'] as Map).cast<String, dynamic>();
    final Map<String, dynamic> tokensJson = (json['tokens'] as Map).cast<String, dynamic>();

    return UserDetails(
      id: user['_id'] as String,
      sub: user['sub'] as String,
      name: user['name'] as String,
      email: user['email'] as String,
      imageUrl: user['image'] as String,
      role: user['role'] as String,
      faculty: user['faculty'] as String? ?? '',
      banned: user['banned'] as bool,
      tokens: Tokens(
        accessToken: tokensJson['access_token'] as String,
        refreshToken: tokensJson['refresh_token'] as String,
      ),
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
      banned: banned,
    );
  }

  @override
  String toString() {
    return 'UserInformationResponse{id: $id, sub: $sub, name: $name, email: $email, imageUrl: $imageUrl, role: $role, faculty: $faculty, banned: $banned, tokens: $tokens}';
  }
}

class Tokens {
  final String accessToken;
  final String refreshToken;

  Tokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  @override
  String toString() {
    return 'Tokens{accessToken: $accessToken, refreshToken: $refreshToken}';
  }
}