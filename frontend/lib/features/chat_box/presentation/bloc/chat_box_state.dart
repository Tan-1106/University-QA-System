part of 'chat_box_bloc.dart';

@immutable
sealed class ChatBoxState {
  const ChatBoxState();
}

final class ChatBoxInitial extends ChatBoxState {}

final class ChatBoxLoading extends ChatBoxState {}

final class ChatBoxQuestionAnswered extends ChatBoxState {
  final QaRecord qaRecord;

  const ChatBoxQuestionAnswered(this.qaRecord);
}

final class ChatBoxError extends ChatBoxState {
  final String message;

  const ChatBoxError(this.message);
}
