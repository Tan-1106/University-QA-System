part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardEvent {}

final class GetDashboardStatisticsEvent extends DashboardEvent {
  GetDashboardStatisticsEvent();
}

final class GetDashboardQuestionsEvent extends DashboardEvent {
  final int page;
  final String? feedbackType;
  final bool isLoadMore;

  GetDashboardQuestionsEvent({
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
