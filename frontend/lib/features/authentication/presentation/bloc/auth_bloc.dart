import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/core/utils/app_bloc_observer.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';
import 'package:university_qa_system/features/authentication/domain/usecases/sign_in_with_elit.dart';
import 'package:university_qa_system/features/authentication/domain/usecases/verify_user_access.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithELIT _signInWithELIT;
  final VerifyUserAccess _verifyUserAccess;

  AuthBloc(
    SignInWithELIT signInWithELIT,
    VerifyUserAccess verifyUserAccess,
  ) : _signInWithELIT = signInWithELIT,
      _verifyUserAccess = verifyUserAccess,
      super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignInWithELIT>(_onGetUserInformation);
    on<AuthVerifyUserAccess>(_onVerifyUserAccess);
  }

  void _onGetUserInformation(
    AuthSignInWithELIT event,
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
    AuthVerifyUserAccess event,
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
