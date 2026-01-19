part of 'chat_bloc.dart';

@immutable
sealed class ChatState {
  const ChatState();
}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatQuestionAnswered extends ChatState {
  final QuestionEntity question;

  const ChatQuestionAnswered(this.question);
}

final class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);
}
