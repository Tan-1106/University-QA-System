part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {
  const DashboardState();
}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardStatisticLoaded extends DashboardState {
  final Statistic statisticData;

  const DashboardStatisticLoaded(this.statisticData);
}

 final class DashboardDataLoaded extends DashboardState {
  final Statistic statisticData;
  final List<Questions> questions;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;

  const DashboardDataLoaded({
    required this.statisticData,
    required this.questions,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  DashboardDataLoaded copyWith({
    Statistic? statisticData,
    List<Questions>? questions,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return DashboardDataLoaded(
      statisticData: statisticData ?? this.statisticData,
      questions: questions ?? this.questions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class DashboardQuestionRecordsLoaded extends DashboardState {
  final List<Questions> questions;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;

  const DashboardQuestionRecordsLoaded({
    required this.questions,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  DashboardQuestionRecordsLoaded copyWith({
    List<Questions>? questions,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return DashboardQuestionRecordsLoaded(
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
