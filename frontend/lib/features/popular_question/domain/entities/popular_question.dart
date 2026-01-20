class PopularQuestionEntity {
  final String id;
  final String question;
  final String answer;
  final SummaryEntity summary;
  final bool isDisplay;
  final String createdAt;
  final String? updatedAt;

  PopularQuestionEntity({
    required this.id,
    required this.question,
    required this.answer,
    required this.summary,
    required this.isDisplay,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  String toString() {
    return 'PopularQuestionEntity{id: $id, question: $question, answer: $answer, summary: $summary, isDisplay: $isDisplay, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

class SummaryEntity {
  final String? facultyScope;
  final String? startDate;
  final String? endDate;
  final int count;

  SummaryEntity({
    this.facultyScope,
    this.startDate,
    this.endDate,
    required this.count,
  });

  @override
  String toString() {
    return 'SummaryEntity{facultyScope: $facultyScope, startDate: $startDate, endDate: $endDate, count: $count}';
  }
}
