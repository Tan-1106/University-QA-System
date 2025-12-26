part of 'admin_pq_bloc.dart';

@immutable
sealed class AdminPQEvent {}

final class GetAdminPopularQuestionsEvent extends AdminPQEvent {
  final int page;
  final bool isDisplay;
  final String? faculty;
  final bool isLoadMore;

  GetAdminPopularQuestionsEvent({
    this.page = 1,
    this.isDisplay = true,
    this.faculty,
    this.isLoadMore = false,
  });
}

final class LoadExistingFacultiesEvent extends AdminPQEvent {}
