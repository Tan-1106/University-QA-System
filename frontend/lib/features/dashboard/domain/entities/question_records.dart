class QuestionRecords {
  final List<Questions> questions;
  final int total;
  final int totalPages;
  final int currentPage;

  QuestionRecords({
    required this.questions,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });
}

class Questions {
  final String id;
  final String userId;
  final String userSub;
  final String question;
  final String? feedback;
  final String createdAt;

  Questions({
    required this.id,
    required this.userId,
    required this.userSub,
    required this.question,
    this.feedback,
    required this.createdAt,
  });
}
