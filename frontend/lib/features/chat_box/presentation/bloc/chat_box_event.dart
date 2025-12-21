part of 'chat_box_bloc.dart';

@immutable
sealed class ChatBoxEvent {}

final class AskQuestionEvent extends ChatBoxEvent {
  final String question;

  AskQuestionEvent({
    required this.question,
  });
}
