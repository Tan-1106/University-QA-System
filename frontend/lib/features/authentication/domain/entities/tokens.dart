class TokensEntity {
  final String accessToken;
  final String refreshToken;

  TokensEntity({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokensEntity.fromJson(Map<String, dynamic> json) {
    return TokensEntity(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  @override
  String toString() {
    return 'Tokens{accessToken: $accessToken, refreshToken: $refreshToken}';
  }
}
