class Documents {
  final List<Document> documents;
  final int total;
  final int totalPages;
  final int currentPage;

  Documents({
    required this.documents,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });
}

class Document {
  final String id;
  final String fileName;
  final String docType;
  final String? department;
  final String? faculty;
  final String uploadedAt;

  Document({
    required this.id,
    required this.fileName,
    required this.docType,
    this.department,
    this.faculty,
    required this.uploadedAt,
  });
}
