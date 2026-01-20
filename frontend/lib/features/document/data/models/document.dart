import 'package:university_qa_system/features/document/domain/entities/document.dart';

class DocumentModel {
  final String id;
  final String fileName;
  final String docType;
  final String? department;
  final String? faculty;
  final String uploadedAt;

  DocumentModel({
    required this.id,
    required this.fileName,
    required this.docType,
    this.department,
    this.faculty,
    required this.uploadedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      docType: json['doc_type'] as String,
      department: json['department'] as String?,
      faculty: json['faculty'] as String?,
      uploadedAt: json['uploaded_at'] as String,
    );
  }

  DocumentEntity toEntity() {
    return DocumentEntity(
      id: id,
      fileName: fileName,
      docType: docType,
      department: department,
      faculty: faculty,
      uploadedAt: uploadedAt,
    );
  }
}