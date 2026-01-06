part of 'user_management_bloc.dart';

@immutable
sealed class UserManagementEvent {}

final class LoadBasicInformationEvent extends UserManagementEvent {
  final String? role;
  final String? faculty;
  final bool? banned;
  final String? keyword;

  LoadBasicInformationEvent({
    this.role,
    this.faculty,
    this.banned,
    this.keyword,
  });
}

final class LoadUserListEvent extends UserManagementEvent {
  final int page;
  final String? role;
  final String? faculty;
  final bool? banned;
  final String? keyword;
  final bool isLoadMore;

  LoadUserListEvent({
    this.page = 1,
    this.role,
    this.faculty,
    this.banned,
    this.keyword,
    this.isLoadMore = false,
  });
}

final class AssignRoleToUserEvent extends UserManagementEvent {
  final String userId;
  final String roleToAssign;
  final String? faculty;

  AssignRoleToUserEvent({
    required this.userId,
    required this.roleToAssign,
    this.faculty,
  });
}

final class ChangeUserBanStatusEvent extends UserManagementEvent {
  final String userId;
  final bool currentBanStatus;

  ChangeUserBanStatusEvent({
    required this.userId,
    required this.currentBanStatus,
  });
}


