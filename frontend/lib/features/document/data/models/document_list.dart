import 'package:university_qa_system/features/document/data/models/document.dart';
import 'package:university_qa_system/features/document/domain/entities/document_list.dart';

class DocumentListModel {
  final List<DocumentModel> documents;
  final int total;
  final int totalPages;
  final int currentPage;

  DocumentListModel({
    required this.documents,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory DocumentListModel.fromJson(Map<String, dynamic> json) {
    var documentsJson = json['documents'] as List<dynamic>;
    List<DocumentModel> documentsList = documentsJson
        .map(
          (documentJson) => DocumentModel(
            id: documentJson['id'] as String,
            fileName: documentJson['file_name'] as String,
            docType: documentJson['doc_type'] as String,
            department: documentJson['department'] as String?,
            faculty: documentJson['faculty'] as String?,
            uploadedAt: documentJson['uploaded_at'] as String,
          ),
        )
        .toList();

    return DocumentListModel(
      documents: documentsList,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }

  DocumentListEntity toEntity() {
    return DocumentListEntity(
      documents: documents.map((d) => d.toEntity()).toList(),
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