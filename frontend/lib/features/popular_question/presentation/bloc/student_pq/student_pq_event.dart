part of 'student_pq_bloc.dart';

@immutable
sealed class StudentPQEvent {}

final class GetStudentPopularQuestionsEvent extends StudentPQEvent {
  final bool facultyOnly;

  GetStudentPopularQuestionsEvent({
    this.facultyOnly = false,
  });
}
