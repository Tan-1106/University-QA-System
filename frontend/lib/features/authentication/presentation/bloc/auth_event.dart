part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignInWithELITEvent extends AuthEvent {
  final String authCode;

  AuthSignInWithELITEvent({
    required this.authCode,
  });
}

final class AuthVerifyUserAccessEvent extends AuthEvent {}
