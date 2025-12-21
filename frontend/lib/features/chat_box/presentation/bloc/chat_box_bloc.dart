import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_record.dart';
import 'package:university_qa_system/features/chat_box/domain/use_cases/ask_question.dart';

part 'chat_box_event.dart';

part 'chat_box_state.dart';

class ChatBoxBloc extends Bloc<ChatBoxEvent, ChatBoxState> {
  final AskQuestionUseCase _askQuestion;

  ChatBoxBloc(
    AskQuestionUseCase askQuestion,
  ) : _askQuestion = askQuestion,
      super(
        ChatBoxInitial(),
      ) {
    on<AskQuestionEvent>(_onAskQuestion);
  }

  void _onAskQuestion(AskQuestionEvent event, Emitter<ChatBoxState> emit) async {
    emit(ChatBoxLoading());

    final result = await _askQuestion(AskQuestionParams(question: event.question));

    result.fold(
      (failure) => emit(ChatBoxError(failure.message)),
      (qaRecord) => emit(ChatBoxQuestionAnswered(qaRecord)),
    );
  }
}
