part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthGetUserInformation extends AuthEvent {
  final String authCode;

  AuthGetUserInformation({
    required this.authCode,
  });
}
