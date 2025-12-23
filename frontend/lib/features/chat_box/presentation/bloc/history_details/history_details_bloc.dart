import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_record_details.dart';
import 'package:university_qa_system/features/chat_box/domain/use_cases/view_qa_record_details.dart';

part 'history_details_event.dart';

part 'history_details_state.dart';

class HistoryDetailsBloc extends Bloc<HistoryDetailsEvent, HistoryDetailsState> {
  final ViewQARecordDetailsUseCase _viewQARecordDetailsUseCase;

  HistoryDetailsBloc(
    ViewQARecordDetailsUseCase viewQARecordDetailsUseCase,
  ) : _viewQARecordDetailsUseCase = viewQARecordDetailsUseCase,
      super(HistoryDetailsInitial()) {
    on<ViewRecordDetailsEvent>(_onViewRecordDetails);
  }

  void _onViewRecordDetails(
    ViewRecordDetailsEvent event,
    Emitter<HistoryDetailsState> emit,
  ) async {
    emit(HistoryDetailsLoading());

    final result = await _viewQARecordDetailsUseCase(
      ViewQaRecordDetailsParams(questionID: event.questionID),
    );

    result.fold(
      (failure) => emit(HistoryDetailsError(failure.message)),
      (data) => emit(HistoryDetailsLoaded(data)),
    );
  }
}
