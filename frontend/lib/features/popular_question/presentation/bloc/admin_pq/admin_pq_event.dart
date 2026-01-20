part of 'admin_pq_bloc.dart';

@immutable
sealed class AdminPQEvent {}

final class GeneratePopularQuestionsEvent extends AdminPQEvent {}

final class GetAdminPopularQuestionsEvent extends AdminPQEvent {
  final String? faculty;
  final bool isDisplay;

  GetAdminPopularQuestionsEvent({
    this.faculty,
    this.isDisplay = true,
  });
}

final class GetFacultiesEvent extends AdminPQEvent {}

final class AssignFacultyScopeEvent extends AdminPQEvent {
  final String questionId;
  final String? faculty;

  AssignFacultyScopeEvent({
    required this.questionId,
    required this.faculty,
  });
}

final class UpdateQuestionEvent extends AdminPQEvent {
  final String questionId;
  final String? question;
  final String? answer;

  UpdateQuestionEvent({
    required this.questionId,
    this.question,
    this.answer,
  });
}

final class ToggleQuestionDisplayEvent extends AdminPQEvent {
  final String questionId;

  ToggleQuestionDisplayEvent({
    required this.questionId,
  });
}
