import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/utils/app_bloc_observer.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_history.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_record.dart';
import 'package:university_qa_system/features/chat_box/domain/use_cases/ask_question.dart';
import 'package:university_qa_system/features/chat_box/domain/use_cases/get_qa_history.dart';

part 'chat_box_event.dart';

part 'chat_box_state.dart';

class ChatBoxBloc extends Bloc<ChatBoxEvent, ChatBoxState> {
  final AskQuestionUseCase _askQuestion;
  final GetQAHistoryUseCase _getQAHistory;

  List<QuestionRecord> _qaHistory = [];
  int _currentPage = 0;
  int _totalPages = 1;

  ChatBoxBloc(
    AskQuestionUseCase askQuestion,
    GetQAHistoryUseCase getQAHistory,
  ) : _askQuestion = askQuestion,
      _getQAHistory = getQAHistory,
      super(
        ChatBoxInitial(),
      ) {
    on<AskQuestionEvent>(_onAskQuestion);
    on<GetQAHistoryEvent>(_onGetQAHistory);
  }

  void _onAskQuestion(AskQuestionEvent event, Emitter<ChatBoxState> emit) async {
    emit(ChatBoxLoading());

    final result = await _askQuestion(AskQuestionParams(question: event.question));

    result.fold(
      (failure) => emit(ChatBoxError(failure.message)),
      (qaRecord) => emit(ChatBoxQuestionAnswered(qaRecord)),
    );
  }

  void _onGetQAHistory(
    GetQAHistoryEvent event,
    Emitter<ChatBoxState> emit,
  ) async {
    if (event.isLoadMore) {
      if (state is HistoryLoaded) {
        final currentState = state as HistoryLoaded;
        if (currentState.isLoadingMore || !currentState.hasMore) return;
        emit(currentState.copyWith(isLoadingMore: true));
      }
    } else {
      emit(HistoryLoading());
      _qaHistory = [];
      _currentPage = 1;
    }

    final result = await _getQAHistory(GetQAHistoryParams(page: event.page));

    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (data) {
        if (event.isLoadMore) {
          _qaHistory.addAll(data.questions);
        } else {
          _qaHistory = data.questions;
        }
        _currentPage = data.currentPage;
        _totalPages = data.totalPages;

        emit(
          HistoryLoaded(
            history: List.from(_qaHistory),
            currentPage: _currentPage,
            totalPages: _totalPages,
            hasMore: _currentPage < _totalPages,
            isLoadingMore: false,
          ),
        );
      },
    );
  }
}
