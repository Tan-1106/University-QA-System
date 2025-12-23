part of 'chat_box_bloc.dart';

@immutable
sealed class ChatBoxEvent {}

final class AskQuestionEvent extends ChatBoxEvent {
  final String question;

  AskQuestionEvent({
    required this.question,
  });
}

final class SendFeedbackEvent extends ChatBoxEvent {
  final String questionID;
  final String feedback;

  SendFeedbackEvent({
    required this.questionID,
    required this.feedback,
  });
}

final class ResetChatBoxEvent extends ChatBoxEvent {}
