import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/common/entities/user.dart';
import 'package:university_qa_system/features/authentication/domain/usecases/user_information.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserInformation _userInformation;

  AuthBloc({
    required UserInformation userInformation,
  }) : _userInformation = userInformation,
       super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthGetUserInformation>(_onGetUserInformation);
  }

  void _onGetUserInformation(
    AuthGetUserInformation event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _userInformation(UserInformationParams(authCode: event.authCode));

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
