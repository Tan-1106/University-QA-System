import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_history.dart';
import 'package:university_qa_system/features/chat_box/domain/use_cases/get_qa_history.dart';

part 'history_event.dart';

part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetQAHistoryUseCase _getQAHistory;

  List<QuestionRecord> _qaHistory = [];
  int _currentPage = 0;
  int _totalPages = 1;

  HistoryBloc(
    GetQAHistoryUseCase getQAHistory,
  ) : _getQAHistory = getQAHistory,
      super(HistoryInitial()) {
    on<GetHistoryEvent>(_onGetHistory);
  }

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
