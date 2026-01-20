import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/document/domain/entities/pdf_bytes.dart';
import 'package:university_qa_system/features/document/domain/use_cases/view_document.dart';

part 'document_viewer_event.dart';

part 'document_viewer_state.dart';

class DocumentViewerBloc extends Bloc<DocumentViewerEvent, DocumentViewerState> {
  final ViewDocumentUseCase _viewDocument;

  DocumentViewerBloc(
    ViewDocumentUseCase viewDocument,
  ) : _viewDocument = viewDocument,
      super(DocumentViewerInitial()) {
    on<ViewDocumentEvent>(_onViewDocument);
  }

  // View Document
  void _onViewDocument(
      ViewDocumentEvent event,
      Emitter<DocumentViewerState> emit,
  ) async {
    emit(DocumentViewerLoading());

    final result = await _viewDocument(
      ViewDocumentParams(event.documentId)
    );

    result.fold(
        (failure) => emit(DocumentViewerError(failure.message)),
        (data) => emit(DocumentViewerLoaded(data))
    );
  }
}
