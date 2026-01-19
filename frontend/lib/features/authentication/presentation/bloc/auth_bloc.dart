import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/log_out.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/sign_in_with_elit.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/verify_user_access.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/sign_up_system_account.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/sign_in_with_system_account.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpSystemAccountUseCase _signUpSystemAccount;
  final SignInWithSystemAccountUseCase _signInWithSystemAccount;
  final SignInWithELitUseCase _signInWithELIT;
  final VerifyUserAccessUseCase _verifyUserAccess;
  final LogOutUseCase _logOut;

  AuthBloc(
    SignUpSystemAccountUseCase signUpSystemAccount,
    SignInWithSystemAccountUseCase signInWithSystemAccount,
    SignInWithELitUseCase signInWithELIT,
    VerifyUserAccessUseCase verifyUserAccess,
    LogOutUseCase logOut,
  ) : _signUpSystemAccount = signUpSystemAccount,
      _signInWithSystemAccount = signInWithSystemAccount,
      _signInWithELIT = signInWithELIT,
      _verifyUserAccess = verifyUserAccess,
      _logOut = logOut,
      super(AuthInitial()) {
    on<SignUpSystemAccountEvent>(_onSignUpSystemAccount, transformer: droppable());
    on<SignInWithSystemAccountEvent>(_onSignInWithSystemAccount, transformer: droppable());
    on<SignInWithELITEvent>(_onGetUserInformation, transformer: droppable());
    on<VerifyUserAccessEvent>(_onVerifyUserAccess);
    on<LogOutEvent>(_onLogout);
  }

  // Sign up with system account
  void _onSignUpSystemAccount(
    SignUpSystemAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _signUpSystemAccount(
      SignUpSystemAccountParams(
        name: event.name,
        email: event.email,
        studentId: event.studentId,
        faculty: event.faculty,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  // Sign in with system account
  void _onSignInWithSystemAccount(
    SignInWithSystemAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _signInWithSystemAccount(
      SignInWithSystemAccountParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // Sign in with ELIT
  void _onGetUserInformation(
    SignInWithELITEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _signInWithELIT(SignInWithELitParams(authCode: event.authCode));

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // Verify User Access
  void _onVerifyUserAccess(
    VerifyUserAccessEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _verifyUserAccess.call(NoParams());

    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // Log out
  void _onLogout(
    LogOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUnauthenticated());
    final result = await _logOut.call(NoParams());

    result.fold(
      (failure) => {},
      (_) => {},
    );
  }
}
