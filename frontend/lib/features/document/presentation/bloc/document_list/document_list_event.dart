part of 'document_list_bloc.dart';

@immutable
sealed class DocumentListEvent {}

final class LoadGeneralDocumentsEvent extends DocumentListEvent {
  final int page;
  final String? keyword;
  final String? department;
  final String? documentType;
  final bool isLoadMore;

  LoadGeneralDocumentsEvent({
    this.page = 1,
    this.keyword,
    this.department,
    this.documentType,
    this.isLoadMore = false,
  });
}

final class LoadFacultyDocumentsEvent extends DocumentListEvent {
  final int page;
  final String? keyword;
  final String? documentType;
  final bool isLoadMore;

  LoadFacultyDocumentsEvent({
    this.page = 1,
    this.keyword,
    this.documentType,
    this.isLoadMore = false,
  });
}

final class ResetDocumentListEvent extends DocumentListEvent {}

final class DeleteDocumentEvent extends DocumentListEvent {
  final String documentId;

  DeleteDocumentEvent(this.documentId);
}