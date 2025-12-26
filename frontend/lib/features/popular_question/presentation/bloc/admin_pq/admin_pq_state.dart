part of 'admin_pq_bloc.dart';

@immutable
sealed class AdminPQState {
  const AdminPQState();
}

final class AdminPQInitial extends AdminPQState {}

final class AdminPQLoading extends AdminPQState {}

final class AdminPQFacultiesLoaded extends AdminPQState {
  final List<String> faculties;

  const AdminPQFacultiesLoaded({required this.faculties});
}

final class AdminPQLoaded extends AdminPQState {
  final List<PopularQuestion> questions;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;

  const AdminPQLoaded({
    required this.questions,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  AdminPQLoaded copyWith({
    List<PopularQuestion>? questions,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return AdminPQLoaded(
      questions: questions ?? this.questions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class AdminPQError extends AdminPQState {
  final String message;

  const AdminPQError(this.message);
}

