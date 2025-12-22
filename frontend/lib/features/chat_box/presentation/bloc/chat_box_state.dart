part of 'chat_box_bloc.dart';

@immutable
sealed class ChatBoxState {
  const ChatBoxState();
}

final class ChatBoxInitial extends ChatBoxState {}

final class ChatBoxLoading extends ChatBoxState {}

final class ChatBoxQuestionAnswered extends ChatBoxState {
  final QARecord qaRecord;

  const ChatBoxQuestionAnswered(this.qaRecord);
}

final class ChatBoxError extends ChatBoxState {
  final String message;

  const ChatBoxError(this.message);
}

final class HistoryLoading extends ChatBoxState {}

final class HistoryLoaded extends ChatBoxState {
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

final class HistoryError extends ChatBoxState {
  final String message;

  const HistoryError(this.message);
}