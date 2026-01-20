part of 'document_viewer_bloc.dart';

@immutable
sealed class DocumentViewerEvent {}

final class ViewDocumentEvent extends DocumentViewerEvent {
  final String documentId;

  ViewDocumentEvent(this.documentId);
}
