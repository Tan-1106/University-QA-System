part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignInWithELIT extends AuthEvent {
  final String authCode;

  AuthSignInWithELIT({
    required this.authCode,
  });
}

final class AuthVerifyUserAccess extends AuthEvent {}
