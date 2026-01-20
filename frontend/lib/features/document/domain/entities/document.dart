class DocumentEntity {
  final String id;
  final String fileName;
  final String docType;
  final String? department;
  final String? faculty;
  final String uploadedAt;

  DocumentEntity({
    required this.id,
    required this.fileName,
    required this.docType,
    this.department,
    this.faculty,
    required this.uploadedAt,
  });

  @override
  String toString() {
    return 'Document{id: $id, fileName: $fileName, docType: $docType, department: $department, faculty: $faculty, uploadedAt: $uploadedAt}';
  }
}