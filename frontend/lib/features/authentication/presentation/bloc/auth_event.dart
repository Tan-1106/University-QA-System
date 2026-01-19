part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

// Sign up with system account
final class SignUpSystemAccountEvent extends AuthEvent {
  final String name;
  final String email;
  final String studentId;
  final String faculty;
  final String password;

  SignUpSystemAccountEvent({
    required this.name,
    required this.email,
    required this.studentId,
    required this.faculty,
    required this.password,
  });
}

// Sign in with system account
final class SignInWithSystemAccountEvent extends AuthEvent {
  final String email;
  final String password;

  SignInWithSystemAccountEvent({
    required this.email,
    required this.password,
  });
}

// Sign in with ELIT
final class SignInWithELITEvent extends AuthEvent {
  final String authCode;

  SignInWithELITEvent({
    required this.authCode,
  });
}

// Verify user access (check if user is already authenticated)
final class VerifyUserAccessEvent extends AuthEvent {}

// Log out
final class LogOutEvent extends AuthEvent {}
