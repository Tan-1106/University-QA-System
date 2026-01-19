import 'package:university_qa_system/features/authentication/domain/entities/tokens.dart';

class TokensModel {
  final String accessToken;
  final String refreshToken;

  TokensModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokensModel.fromJson(Map<String, dynamic> json) {
    return TokensModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  TokensEntity toEntity() {
    return TokensEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  String toString() {
    return 'Tokens{accessToken: $accessToken, refreshToken: $refreshToken}';
  }
}