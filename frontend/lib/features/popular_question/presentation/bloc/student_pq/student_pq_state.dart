part of 'student_pq_bloc.dart';

@immutable
sealed class StudentPQState {
  const StudentPQState();
}

final class StudentPQInitial extends StudentPQState {}

final class StudentPQLoading extends StudentPQState {}

final class StudentPQLoaded extends StudentPQState {
  final List<PopularQuestion> questions;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;

  const StudentPQLoaded({
    required this.questions,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  StudentPQLoaded copyWith({
    List<PopularQuestion>? questions,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return StudentPQLoaded(
      questions: questions ?? this.questions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class StudentPQError extends StudentPQState {
  final String message;

  const StudentPQError(this.message);
}
