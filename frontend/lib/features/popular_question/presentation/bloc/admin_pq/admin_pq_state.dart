part of 'admin_pq_bloc.dart';

@immutable
class AdminPQState {
  const AdminPQState();
}

class AdminPQInitial extends AdminPQState {
  const AdminPQInitial();
}

class AdminPQLoading extends AdminPQState {
  const AdminPQLoading();
}

class AdminPQDataState extends AdminPQState {
  final List<PopularQuestion> questions;
  final List<String> faculties;

  const AdminPQDataState({
    required this.questions,
    required this.faculties,
  });

  AdminPQDataState copyWith({
    List<PopularQuestion>? questions,
    List<String>? faculties,
  }) {
    return AdminPQDataState(
      questions: questions ?? this.questions,
      faculties: faculties ?? this.faculties,
    );
  }
}

class AdminPQError extends AdminPQState {
  final String message;

  const AdminPQError(this.message);
}
