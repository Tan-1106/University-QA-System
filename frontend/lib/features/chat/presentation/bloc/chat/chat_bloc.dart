import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/chat/domain/entities/question.dart';
import 'package:university_qa_system/features/chat/domain/use_cases/ask_question.dart';
import 'package:university_qa_system/features/chat/domain/use_cases/send_feedback.dart';

part 'chat_event.dart';

part 'chat_state.dart';

class ChatBoxBloc extends Bloc<ChatBoxEvent, ChatState> {
  final AskQuestionUseCase _askQuestion;
  final SendFeedbackUseCase _sendFeedback;

  ChatBoxBloc(
    AskQuestionUseCase askQuestion,
    SendFeedbackUseCase sendFeedback,
  ) : _askQuestion = askQuestion,
      _sendFeedback = sendFeedback,
      super(ChatInitial()) {
    on<AskQuestionEvent>(_onAskQuestion);
    on<SendFeedbackEvent>(_onSendFeedback);
    on<ResetChatBoxEvent>(_onResetChatBox);
  }

  // Send question and get answer
  void _onAskQuestion(
    AskQuestionEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await _askQuestion(
      AskQuestionParams(
        question: event.question,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (qaRecord) => emit(ChatQuestionAnswered(qaRecord)),
    );
  }

  // Send feedback for a specific question
  void _onSendFeedback(
    SendFeedbackEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await _sendFeedback(
      SendFeedbackParams(
        questionID: event.questionID,
        feedback: event.feedback,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (success) {},
    );
  }

  // Reset chat box to initial state
  void _onResetChatBox(ResetChatBoxEvent event, Emitter<ChatState> emit) {
    emit(ChatInitial());
  }
}
