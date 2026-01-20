import 'package:university_qa_system/features/document/domain/entities/document.dart';

class DocumentListEntity {
  final List<DocumentEntity> documents;
  final int total;
  final int totalPages;
  final int currentPage;

  DocumentListEntity({
    required this.documents,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  String toString() {
    return 'DocumentListEntity{total: $total, totalPages: $totalPages, currentPage: $currentPage, documents: $documents}';
  }
}
