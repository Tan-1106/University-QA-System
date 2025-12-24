part of 'document_viewer_bloc.dart';

@immutable
sealed class DocumentViewerEvent {}

final class LoadDocumentEvent extends DocumentViewerEvent {
  final String documentId;

  LoadDocumentEvent(this.documentId);
}
