part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignInWithSystemAccountEvent extends AuthEvent {
  final String email;
  final String password;

  AuthSignInWithSystemAccountEvent({
    required this.email,
    required this.password,
  });
}

final class AuthRegisterSystemAccountEvent extends AuthEvent {
  final String name;
  final String email;
  final String studentId;
  final String faculty;
  final String password;

  AuthRegisterSystemAccountEvent({
    required this.name,
    required this.email,
    required this.studentId,
    required this.faculty,
    required this.password,
  });
}

final class AuthSignInWithELITEvent extends AuthEvent {
  final String authCode;

  AuthSignInWithELITEvent({
    required this.authCode,
  });
}

final class AuthVerifyUserAccessEvent extends AuthEvent {}

final class LogOutEvent extends AuthEvent {}
