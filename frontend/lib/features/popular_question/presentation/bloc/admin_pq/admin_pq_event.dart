part of 'admin_pq_bloc.dart';

@immutable
sealed class AdminPQEvent {}

final class GeneratePotentialQuestionsEvent extends AdminPQEvent {}

final class GetAdminPopularQuestionsEvent extends AdminPQEvent {
  final String? faculty;
  final bool isDisplay;

  GetAdminPopularQuestionsEvent({
    this.faculty,
    this.isDisplay = true,
  });
}

final class LoadExistingFacultiesEvent extends AdminPQEvent {}
