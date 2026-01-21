part of 'user_management_bloc.dart';

@immutable
sealed class UserManagementState {
  const UserManagementState();
}

final class UserManagementInitial extends UserManagementState {}

final class UserManagementLoading extends UserManagementState {}

final class UserManagementStateLoaded extends UserManagementState {
  final List<String> roles;
  final List<String> faculties;
  final List<UserEntity> users;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMoreUsers;

  const UserManagementStateLoaded({
    required this.roles,
    required this.faculties,
    required this.users,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.isLoadingMoreUsers = false,
  });

  UserManagementStateLoaded copyWith({
    List<String>? roles,
    List<String>? faculties,
    List<UserEntity>? users,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMoreUsers,
  }) {
    return UserManagementStateLoaded(
      roles: roles ?? this.roles,
      faculties: faculties ?? this.faculties,
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMoreUsers: isLoadingMoreUsers ?? this.isLoadingMoreUsers,
    );
  }
}

final class UserManagementError extends UserManagementState {
  final String message;

  const UserManagementError(this.message);
}
