part of 'student_pq_bloc.dart';

@immutable
sealed class StudentPQEvent {}

final class GetStudentPopularQuestionsEvent extends StudentPQEvent {
  final int page;
  final bool facultyOnly;
  final bool isLoadMore;

  GetStudentPopularQuestionsEvent({
    this.page = 1,
    this.facultyOnly = false,
    this.isLoadMore = false,
  });
}
