class TokensEntity {
  final String accessToken;
  final String refreshToken;

  TokensEntity({
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  String toString() {
    return 'Tokens{accessToken: $accessToken, refreshToken: $refreshToken}';
  }
}
