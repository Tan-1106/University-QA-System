import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/entities/filters.dart';
import 'package:university_qa_system/features/document/domain/use_cases/get_existing_filters.dart';


part 'document_filter_event.dart';

part 'document_filter_state.dart';

class DocumentFilterBloc extends Bloc<DocumentFilterEvent, DocumentFilterState> {
  final GetExistingFiltersUseCase _getExistingFilters;

  DocumentFilterBloc(
    GetExistingFiltersUseCase getExistingFiltersUseCase,
  ) : _getExistingFilters = getExistingFiltersUseCase,
      super(DocumentFilterInitial()) {
    on<GetDocumentFiltersEvent>(_onLoadExistingFilters);
  }

  void _onLoadExistingFilters(
    GetDocumentFiltersEvent event,
    Emitter<DocumentFilterState> emit,
  ) async {
    emit(DocumentFiltersLoading());

    final result = await _getExistingFilters(NoParams());
    result.fold(
      (failure) => emit(DocumentFilterError(failure.message)),
      (filters) => emit(DocumentFiltersLoaded(filters)),
    );
  }
}
