import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/user_management/domain/entities/user.dart';
import 'package:university_qa_system/features/user_management/domain/use_cases/get_users.dart';
import 'package:university_qa_system/features/user_management/domain/use_cases/assign_role.dart';
import 'package:university_qa_system/features/user_management/domain/use_cases/get_all_roles.dart';
import 'package:university_qa_system/features/user_management/domain/use_cases/get_all_faculties.dart';
import 'package:university_qa_system/features/user_management/domain/use_cases/change_ban_status.dart';

part 'user_management_event.dart';

part 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final GetAllRolesUseCase _getAllRoles;
  final GetAllFacultiesUseCase _getAllFaculties;
  final GetUsersUseCase _getUsers;
  final AssignRoleUseCase _assignRole;
  final ChangeBanStatusUseCase _changeBanStatus;

  List<String> _roles = [];
  List<String> _faculties = [];
  List<UserEntity> _users = [];
  int _currentPage = 0;
  int _totalPages = 1;

  UserManagementBloc(
    GetAllRolesUseCase getAllRoles,
    GetAllFacultiesUseCase getAllFaculties,
    GetUsersUseCase getUsers,
    AssignRoleUseCase assignRole,
    ChangeBanStatusUseCase changeBanStatus,
  ) : _getAllRoles = getAllRoles,
      _getAllFaculties = getAllFaculties,
      _getUsers = getUsers,
      _assignRole = assignRole,
      _changeBanStatus = changeBanStatus,
      super(UserManagementInitial()) {
    on<GetBasicInformationEvent>(_onGetBasicInformation);
    on<GetUserListEvent>(_onGetUserList);
    on<AssignRoleToUserEvent>(_onAssignRoleToUser);
    on<ChangeUserBanStatusEvent>(_onChangeUserBanStatus);
  }

  // Get user management basic information
  void _onGetBasicInformation(
    GetBasicInformationEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(UserManagementLoading());

    final rolesResult = await _getAllRoles(NoParams());
    final facultiesResult = await _getAllFaculties(NoParams());

    bool hasError = false;

    rolesResult.fold(
      (failure) {
        hasError = true;
        emit(UserManagementError(failure.message));
      },
      (roles) {
        _roles = roles;
      },
    );

    if (hasError) return;

    facultiesResult.fold(
      (failure) {
        hasError = true;
        emit(UserManagementError(failure.message));
      },
      (faculties) {
        _faculties = faculties;
      },
    );

    if (hasError) return;

    emit(
      UserManagementStateLoaded(
        roles: _roles,
        faculties: _faculties,
        users: const [],
        currentPage: 0,
        totalPages: 1,
        hasMore: true,
        isLoadingMoreUsers: false,
      ),
    );

    add(GetUserListEvent(
      role: event.role,
      faculty: event.faculty,
      banned: event.banned,
      keyword: event.keyword,
    ));
  }

  // Get user list with optional filters
  void _onGetUserList(
    GetUserListEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    UserManagementStateLoaded? previousState;

    if (event.isLoadMore) {
      if (state is UserManagementStateLoaded) {
        final currentState = state as UserManagementStateLoaded;
        if (!currentState.hasMore || currentState.isLoadingMoreUsers) return;
        previousState = currentState;
        emit(
          currentState.copyWith(
            isLoadingMoreUsers: true,
          ),
        );
      } else {
        return;
      }
    } else {
      _users = [];
      _currentPage = 0;
      if (state is! UserManagementStateLoaded) {
        emit(UserManagementLoading());
      }
    }

    final pageToLoad = event.isLoadMore ? _currentPage + 1 : event.page;
    final usersResult = await _getUsers(
      GetUsersParams(
        page: pageToLoad,
        role: event.role,
        faculty: event.faculty,
        banned: event.banned,
        keyword: event.keyword,
      ),
    );

    usersResult.fold(
      (failure) {
        if (event.isLoadMore && previousState != null) {
          emit(previousState.copyWith(isLoadingMoreUsers: false));
        } else {
          emit(UserManagementError(failure.message));
        }
      },
      (data) {
        if (event.isLoadMore) {
          _users.addAll(data.users);
        } else {
          _users = data.users;
        }
        _currentPage = data.currentPage;
        _totalPages = data.totalPages;

        emit(
          UserManagementStateLoaded(
            roles: _roles,
            faculties: _faculties,
            users: List.from(_users),
            currentPage: _currentPage,
            totalPages: _totalPages,
            hasMore: _currentPage < _totalPages,
            isLoadingMoreUsers: false,
          ),
        );
      },
    );
  }

  // Assign role to a user
  void _onAssignRoleToUser(
    AssignRoleToUserEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    final result = await _assignRole(
      AssignRoleParams(
        userId: event.userId,
        roleToAssign: event.roleToAssign,
        faculty: event.faculty,
      ),
    );

    result.fold(
      (failure) => emit(UserManagementError(failure.message)),
      (_) {},
    );
  }

  // Change user ban status
  void _onChangeUserBanStatus(
    ChangeUserBanStatusEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    final result = await _changeBanStatus(
      ChangeBanStatusParams(
        userId: event.userId,
        currentBanStatus: event.currentBanStatus,
      ),
    );

    result.fold(
      (failure) => emit(UserManagementError(failure.message)),
      (_) {},
    );
  }
}
