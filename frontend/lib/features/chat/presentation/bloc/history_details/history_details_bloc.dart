import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/chat/domain/entities/question_details.dart';
import 'package:university_qa_system/features/chat/domain/use_cases/view_question_details.dart';

part 'history_details_event.dart';

part 'history_details_state.dart';

class HistoryDetailsBloc extends Bloc<HistoryDetailsEvent, HistoryDetailsState> {
  final ViewQuestionDetailsUseCase _viewQuestionDetailsUseCase;

  HistoryDetailsBloc(
    ViewQuestionDetailsUseCase viewQuestionDetailsUseCase,
  ) : _viewQuestionDetailsUseCase = viewQuestionDetailsUseCase,
      super(HistoryDetailsInitial()) {
    on<ViewRecordDetailsEvent>(_onViewRecordDetails);
  }

  // View details of a specific question record
  void _onViewRecordDetails(
    ViewRecordDetailsEvent event,
    Emitter<HistoryDetailsState> emit,
  ) async {
    emit(HistoryDetailsLoading());

    final result = await _viewQuestionDetailsUseCase(
      ViewQuestionDetailsParams(
        questionID: event.questionID,
      ),
    );

    result.fold(
      (failure) => emit(HistoryDetailsError(failure.message)),
      (data) => emit(HistoryDetailsLoaded(data)),
    );
  }
}
