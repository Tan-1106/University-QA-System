import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/chat/domain/entities/question.dart';
import 'package:university_qa_system/features/chat/domain/use_cases/get_question_history.dart';

part 'history_event.dart';

part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetQuestionHistoryUseCase _getQuestionHistory;

  List<QuestionEntity> _questionHistory = [];
  int _currentPage = 0;
  int _totalPages = 1;

  HistoryBloc(
    GetQuestionHistoryUseCase getQuestionHistory,
  ) : _getQuestionHistory = getQuestionHistory,
      super(HistoryInitial()) {
    on<GetHistoryEvent>(_onGetHistory);
  }

  // Get question history with pagination
  void _onGetHistory(
    GetHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    if (event.isLoadMore) {
      if (state is HistoryLoaded) {
        final currentState = state as HistoryLoaded;
        if (currentState.isLoadingMore || !currentState.hasMore) return;

        emit(currentState.copyWith(isLoadingMore: true));
      }
    } else {
      emit(HistoryLoading());
      _questionHistory = [];
      _currentPage = 1;
    }

    final result = await _getQuestionHistory(
      GetQuestionHistoryParams(
        page: event.page,
      ),
    );

    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (data) {
        if (event.isLoadMore) {
          _questionHistory.addAll(data.questions);
        } else {
          _questionHistory = data.questions;
        }
        _currentPage = data.currentPage;
        _totalPages = data.totalPages;

        emit(
          HistoryLoaded(
            history: List.from(_questionHistory),
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
