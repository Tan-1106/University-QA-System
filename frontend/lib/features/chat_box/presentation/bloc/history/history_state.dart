part of 'history_bloc.dart';

@immutable
sealed class HistoryState {
  const HistoryState();
}

final class HistoryInitial extends HistoryState {}

final class HistoryLoading extends HistoryState {}

final class HistoryLoaded extends HistoryState {
  final List<QuestionRecord> history;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;

  const HistoryLoaded({
    required this.history,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  HistoryLoaded copyWith({
    List<QuestionRecord>? history,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HistoryLoaded(
      history: history ?? this.history,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);
}



