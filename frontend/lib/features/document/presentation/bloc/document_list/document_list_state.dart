part of 'document_list_bloc.dart';

@immutable
sealed class DocumentListState {
  const DocumentListState();
}

final class DocumentListInitial extends DocumentListState {}

final class DocumentListLoading extends DocumentListState {}

final class DocumentListLoaded extends DocumentListState {
  final List<Document> documents;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;

  const DocumentListLoaded({
    required this.documents,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  DocumentListLoaded copyWith({
    List<Document>? documents,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return DocumentListLoaded(
      documents: documents ?? this.documents,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class DocumentListError extends DocumentListState {
  final String message;

  const DocumentListError(this.message);
}
