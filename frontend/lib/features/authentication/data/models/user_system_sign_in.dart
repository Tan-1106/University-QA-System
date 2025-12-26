import 'package:university_qa_system/features/authentication/data/models/user_details.dart';

class UserSystemSignIn {
  final String accessToken;
  final String refreshToken;

  UserSystemSignIn({
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserSystemSignIn.fromJson(Map<String, dynamic> json) {
    return UserSystemSignIn(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  Tokens toEntity() {
    return Tokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  String toString() {
    return 'UserSystemSignIn{accessToken: $accessToken, refreshToken: $refreshToken}';
  }
}