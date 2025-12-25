class PopularQuestions {
  final List<PopularQuestion> popularQuestions;
  final int total;
  final int totalPages;
  final int currentPage;

  PopularQuestions({
    required this.popularQuestions,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });
}

class PopularQuestion {
  final String id;
  final String question;
  final String answer;
  final Summary summary;
  final bool isDisplay;
  final String createdAt;
  final String? updatedAt;

  PopularQuestion({
    required this.id,
    required this.question,
    required this.answer,
    required this.summary,
    required this.isDisplay,
    required this.createdAt,
    this.updatedAt,
  });
}

class Summary {
  final String? facultyScope;
  final String? startDate;
  final String? endDate;
  final int count;

  Summary({
    this.facultyScope,
    this.startDate,
    this.endDate,
    required this.count,
  });
}
