import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/log_out.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/sign_in_with_elit.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/sign_in_with_system_account.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/system_account_registration.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/verify_user_access.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SystemAccountRegistrationUseCase _systemAccountRegistration;
  final SignInWithSystemAccountUseCase _signInWithSystemAccount;
  final SignInWithELITUseCase _signInWithELIT;
  final VerifyUserAccessUseCase _verifyUserAccess;
  final LogOutUseCase _logOut;

  AuthBloc(
    SystemAccountRegistrationUseCase systemAccountRegistration,
    SignInWithSystemAccountUseCase signInWithSystemAccount,
    SignInWithELITUseCase signInWithELIT,
    VerifyUserAccessUseCase verifyUserAccess,
    LogOutUseCase logOut,
  ) : _systemAccountRegistration = systemAccountRegistration,
      _signInWithSystemAccount = signInWithSystemAccount,
      _signInWithELIT = signInWithELIT,
      _verifyUserAccess = verifyUserAccess,
      _logOut = logOut,
      super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthRegisterSystemAccountEvent>(_onRegisterSystemAccount);
    on<AuthSignInWithSystemAccountEvent>(_onSignInWithSystemAccount);
    on<AuthSignInWithELITEvent>(_onGetUserInformation);
    on<AuthVerifyUserAccessEvent>(_onVerifyUserAccess);
    on<LogoutEvent>(_onLogout);
  }

  void _onRegisterSystemAccount(
    AuthRegisterSystemAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _systemAccountRegistration(
      SystemAccountRegistrationParams(
        name: event.name,
        email: event.email,
        studentId: event.studentId,
        faculty: event.faculty,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthRegistered()),
    );
  }

  void _onSignInWithSystemAccount(
    AuthSignInWithSystemAccountEvent event,
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
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onGetUserInformation(
    AuthSignInWithELITEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _signInWithELIT(VerifyParams(authCode: event.authCode));

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onVerifyUserAccess(
    AuthVerifyUserAccessEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _verifyUserAccess.call(NoParams());

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _emitAuthSuccess(
    User user,
    Emitter<AuthState> emit,
  ) {
    emit(AuthSuccess(user));
  }

  void _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _logOut.call(NoParams());

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthLoggedOut()),
    );
  }
}
