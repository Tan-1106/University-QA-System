import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_record.dart';
import 'package:university_qa_system/features/chat_box/domain/use_cases/ask_question.dart';
import 'package:university_qa_system/features/chat_box/domain/use_cases/send_feedback.dart';

part 'chat_box_event.dart';

part 'chat_box_state.dart';

class ChatBoxBloc extends Bloc<ChatBoxEvent, ChatBoxState> {
  final AskQuestionUseCase _askQuestion;
  final SendFeedbackUseCase _sendFeedback;

  ChatBoxBloc(
    AskQuestionUseCase askQuestion,
    SendFeedbackUseCase sendFeedback,
  ) : _askQuestion = askQuestion,
      _sendFeedback = sendFeedback,
      super(ChatBoxInitial()) {
    on<AskQuestionEvent>(_onAskQuestion);
    on<SendFeedbackEvent>(_onSendFeedback);
    on<ResetChatBoxEvent>(_onResetChatBox);
  }

  // Send question and get answer
  void _onAskQuestion(AskQuestionEvent event, Emitter<ChatBoxState> emit) async {
    emit(ChatBoxLoading());

    final result = await _askQuestion(AskQuestionParams(question: event.question));

    result.fold(
      (failure) => emit(ChatBoxError(failure.message)),
      (qaRecord) => emit(ChatBoxQuestionAnswered(qaRecord)),
    );
  }

  void _onSendFeedback(SendFeedbackEvent event, Emitter<ChatBoxState> emit) async {
    final result = await _sendFeedback(
      SendFeedbackParams(
        questionID: event.questionID,
        feedback: event.feedback,
      ),
    );

    result.fold(
      (failure) => emit(ChatBoxError(failure.message)),
      (success) {},
    );
  }

  void _onResetChatBox(ResetChatBoxEvent event, Emitter<ChatBoxState> emit) {
    emit(ChatBoxInitial());
  }
}
