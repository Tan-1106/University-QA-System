part of 'document_viewer_bloc.dart';

@immutable
sealed class DocumentViewerState {
  const DocumentViewerState();
}

final class DocumentViewerInitial extends DocumentViewerState {}

final class DocumentViewerLoading extends DocumentViewerState {}

final class DocumentViewerLoaded extends DocumentViewerState {
  final PDFBytes pdfBytes;

  const DocumentViewerLoaded(this.pdfBytes);
}

final class DocumentViewerError extends DocumentViewerState {
  final String message;

  const DocumentViewerError(this.message);
}
