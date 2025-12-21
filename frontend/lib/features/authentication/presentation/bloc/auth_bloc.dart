import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/sign_in_with_elit.dart';
import 'package:university_qa_system/features/authentication/domain/use_cases/verify_user_access.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithELITUseCase _signInWithELIT;
  final VerifyUserAccessUseCase _verifyUserAccess;

  AuthBloc(
    SignInWithELITUseCase signInWithELIT,
    VerifyUserAccessUseCase verifyUserAccess,
  ) : _signInWithELIT = signInWithELIT,
      _verifyUserAccess = verifyUserAccess,
      super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignInWithELITEvent>(_onGetUserInformation);
    on<AuthVerifyUserAccessEvent>(_onVerifyUserAccess);
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
}
