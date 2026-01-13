part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardEvent {}

final class LoadDashboardStatisticEvent extends DashboardEvent {
  LoadDashboardStatisticEvent();
}

final class LoadDashboardQuestionRecordsEvent extends DashboardEvent {
  final int page;
  final String? feedbackType;
  final bool isLoadMore;

  LoadDashboardQuestionRecordsEvent({
    this.page = 1,
    this.feedbackType,
    this.isLoadMore = false,
  });
}

final class RespondToQuestionEvent extends DashboardEvent {
  final String questionId;
  final String response;

  RespondToQuestionEvent({
    required this.questionId,
    required this.response,
  });
}
