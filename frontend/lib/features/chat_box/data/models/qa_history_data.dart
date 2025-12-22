import 'package:university_qa_system/features/chat_box/domain/entities/qa_history.dart';

class QAHistoryData {
  final List<QuestionRecord> questions;
  final int total;
  final int totalPages;
  final int currentPage;

  const QAHistoryData({
    required this.questions,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory QAHistoryData.fromJson(Map<String, dynamic> json) {
    var recordsJson = json['questions'] as List<dynamic>;
    List<QuestionRecord> recordsList = recordsJson
        .map(
          (recordJson) => QuestionRecord(
            id: recordJson['_id'] as String,
            question: recordJson['question'] as String,
          ),
        )
        .toList();

    return QAHistoryData(
      questions: recordsList,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }

  QAHistory toEntity() {
    return QAHistory(
      questions: questions,
      total: total,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  @override
  String toString() {
    return 'QAHistoryData(questions: $questions, total: $total, totalPages: $totalPages, currentPage: $currentPage)';
  }
}

