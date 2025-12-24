import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/document/domain/entities/documents.dart';
import 'package:university_qa_system/features/document/domain/use_cases/get_faculty_documents.dart';
import 'package:university_qa_system/features/document/domain/use_cases/get_general_documents.dart';

part 'document_list_event.dart';

part 'document_list_state.dart';

class DocumentListBloc extends Bloc<DocumentListEvent, DocumentListState> {
  final GetGeneralDocumentsUseCase _getGeneralDocuments;
  final GetFacultyDocumentsUseCase _getFacultyDocuments;

  List<Document> _allDocuments = [];
  int _currentPage = 0;
  int _totalPages = 1;

  DocumentListBloc(
    GetGeneralDocumentsUseCase getGeneralDocuments,
    GetFacultyDocumentsUseCase getFacultyDocuments,
  ) : _getGeneralDocuments = getGeneralDocuments,
      _getFacultyDocuments = getFacultyDocuments,
      super(DocumentListInitial()) {
    on<LoadGeneralDocumentsEvent>(_onLoadGeneralDocuments);
    on<LoadFacultyDocumentsEvent>(_onLoadFacultyDocuments);
    on<ResetDocumentListEvent>(_resetDocumentList);
  }

  void _onLoadGeneralDocuments(
      LoadGeneralDocumentsEvent event,
      Emitter<DocumentListState> emit,
  ) async {
    if (event.isLoadMore) {
      if (state is DocumentListLoaded) {
        final currentState = state as DocumentListLoaded;
        if (currentState.isLoadingMore || !currentState.hasMore) return;
        emit(currentState.copyWith(isLoadingMore: true));
      }
    } else {
      _allDocuments = [];
      _currentPage = 0;
    }

    final result = await _getGeneralDocuments(
      GetGeneralDocumentsParams(
        page: event.page,
        keyword: event.keyword,
        department: event.department,
        documentType: event.documentType
      )
    );

    result.fold(
        (failure) => emit(DocumentListError(failure.message)),
        (data) {
          if (event.isLoadMore) {
            _allDocuments.addAll(data.documents);
          } else {
            _allDocuments = data.documents;
          }
          _currentPage = data.currentPage;
          _totalPages = data.totalPages;

          emit(
            DocumentListLoaded(
              documents: List.from(_allDocuments),
              currentPage: _currentPage,
              totalPages: _totalPages,
              hasMore: _currentPage < _totalPages,
              isLoadingMore: false,
            ),
          );
        }
    );
  }

  void _onLoadFacultyDocuments(
      LoadFacultyDocumentsEvent event,
      Emitter<DocumentListState> emit,
  ) async {
    if (event.isLoadMore) {
      if (state is DocumentListLoaded) {
        final currentState = state as DocumentListLoaded;
        if (currentState.isLoadingMore || !currentState.hasMore) return;
        emit(currentState.copyWith(isLoadingMore: true));
      }
    } else {
      _allDocuments = [];
      _currentPage = 0;
    }

    final result = await _getFacultyDocuments(
      GetFacultyDocumentsParams(
        page: event.page,
        keyword: event.keyword,
        documentType: event.documentType,
      )
    );

    result.fold(
        (failure) => emit(DocumentListError(failure.message)),
        (data) {
          if (event.isLoadMore) {
            _allDocuments.addAll(data.documents);
          } else {
            _allDocuments = data.documents;
          }
          _currentPage = data.currentPage;
          _totalPages = data.totalPages;

          emit(
            DocumentListLoaded(
              documents: List.from(_allDocuments),
              currentPage: _currentPage,
              totalPages: _totalPages,
              hasMore: _currentPage < _totalPages,
              isLoadingMore: false,
            ),
          );
        }
    );
  }

  void _resetDocumentList(
      ResetDocumentListEvent event,
      Emitter<DocumentListState> emit,
  ) {
    _allDocuments = [];
    _currentPage = 0;
    _totalPages = 1;
    emit(DocumentListInitial());
  }
}
