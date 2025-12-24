import 'package:university_qa_system/features/document/domain/entities/documents.dart';

class DocumentsData {
  final List<Document> documents;
  final int total;
  final int totalPages;
  final int currentPage;

  DocumentsData({
    required this.documents,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory DocumentsData.fromJson(Map<String, dynamic> json) {
    var documentsJson = json['documents'] as List<dynamic>;
    List<Document> documentsList = documentsJson
        .map(
          (documentJson) => Document(
            id: documentJson['id'] as String,
            fileName: documentJson['file_name'] as String,
            docType: documentJson['doc_type'] as String,
            department: documentJson['department'] as String?,
            faculty: documentJson['faculty'] as String?,
            uploadedAt: documentJson['uploaded_at'] as String,
          ),
        )
        .toList();

    return DocumentsData(
      documents: documentsList,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }

  Documents toEntity() {
    return Documents(
      documents: documents,
      total: total,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  @override
  String toString() {
    return 'DocumentsData{total: $total, totalPages: $totalPages, currentPage: $currentPage, documents: $documents}';
  }
}