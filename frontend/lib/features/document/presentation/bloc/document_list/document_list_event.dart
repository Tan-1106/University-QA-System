part of 'document_list_bloc.dart';

@immutable
sealed class DocumentListEvent {}

final class GetGeneralDocumentsEvent extends DocumentListEvent {
  final int page;
  final String? keyword;
  final String? department;
  final String? documentType;
  final bool isLoadMore;

  GetGeneralDocumentsEvent({
    this.page = 1,
    this.keyword,
    this.department,
    this.documentType,
    this.isLoadMore = false,
  });
}

final class GetFacultyDocumentsEvent extends DocumentListEvent {
  final int page;
  final String? keyword;
  final String? documentType;
  final String? faculty;
  final bool isLoadMore;

  GetFacultyDocumentsEvent({
    this.page = 1,
    this.keyword,
    this.documentType,
    this.faculty,
    this.isLoadMore = false,
  });
}

final class ResetDocumentListEvent extends DocumentListEvent {}

final class DeleteDocumentEvent extends DocumentListEvent {
  final String documentId;

  DeleteDocumentEvent(this.documentId);
}