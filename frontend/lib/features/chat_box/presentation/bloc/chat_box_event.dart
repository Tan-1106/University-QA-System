part of 'chat_box_bloc.dart';

@immutable
sealed class ChatBoxEvent {}

final class AskQuestionEvent extends ChatBoxEvent {
  final String question;

  AskQuestionEvent({
    required this.question,
  });
}

final class GetQAHistoryEvent extends ChatBoxEvent {
  final int page;
  final bool isLoadMore;

  GetQAHistoryEvent({
    this.page = 1,
    this.isLoadMore = false,
  });
}
