class QAHistory {
  final List<QuestionRecord> questions;
  final int total;
  final int totalPages;
  final int currentPage;

  const QAHistory({
    required this.questions,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });
}

class QuestionRecord {
  final String id;
  final String question;

  const QuestionRecord({
    required this.id,
    required this.question,
  });
}