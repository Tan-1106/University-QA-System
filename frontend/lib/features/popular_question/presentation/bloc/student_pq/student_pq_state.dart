part of 'student_pq_bloc.dart';

@immutable
sealed class StudentPQState {
  const StudentPQState();
}

final class StudentPQInitial extends StudentPQState {}

final class StudentPQLoading extends StudentPQState {}

final class StudentPQLoaded extends StudentPQState {
  final List<PopularQuestionEntity> questions;

  const StudentPQLoaded({
    required this.questions,
  });
}

final class StudentPQError extends StudentPQState {
  final String message;

  const StudentPQError(this.message);
}
