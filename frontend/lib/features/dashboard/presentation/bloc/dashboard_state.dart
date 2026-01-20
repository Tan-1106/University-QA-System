part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {
  const DashboardState();
}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardStatisticsLoaded extends DashboardState {
  final DashboardStatisticsEntity statistics;

  const DashboardStatisticsLoaded(this.statistics);
}

final class DashboardQuestionsLoaded extends DashboardState {
  final List<DashboardQuestionEntity> questions;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;

  const DashboardQuestionsLoaded({
    required this.questions,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  DashboardQuestionsLoaded copyWith({
    List<DashboardQuestionEntity>? questions,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return DashboardQuestionsLoaded(
      questions: questions ?? this.questions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class DashboardDataLoaded extends DashboardState {
  final DashboardStatisticsEntity statistics;
  final List<DashboardQuestionEntity> questions;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;

  const DashboardDataLoaded({
    required this.statistics,
    required this.questions,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  DashboardDataLoaded copyWith({
    DashboardStatisticsEntity? statistics,
    List<DashboardQuestionEntity>? questions,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return DashboardDataLoaded(
      statistics: statistics ?? this.statistics,
      questions: questions ?? this.questions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);
}
