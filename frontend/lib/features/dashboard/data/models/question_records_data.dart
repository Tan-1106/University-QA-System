import 'package:university_qa_system/features/dashboard/domain/entities/question_records.dart';

class QuestionRecordsData {
  final List<Question> questions;
  final int total;
  final int totalPages;
  final int currentPage;

  QuestionRecordsData({
    required this.questions,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory QuestionRecordsData.fromJson(Map<String, dynamic> json) {
    var recordsJson = json['questions'] as List<dynamic>;
    List<Question> recordsList = recordsJson
        .map(
          (recordJson) => Question(
            id: recordJson['_id'] as String,
            userId: recordJson['user_id'] as String,
            userSub: recordJson['user_sub'] as String,
            question: recordJson['question'] as String,
            answer: recordJson['answer'] as String?,
            feedback: recordJson['feedback'] as String?,
            managerAnswer: recordJson['manager_answer'] as String?,
            createdAt: recordJson['created_at'] as String,
          ),
        )
        .toList();

    return QuestionRecordsData(
      questions: recordsList,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }

  QuestionRecords toEntity() {
    return QuestionRecords(
      questions: questions,
      total: total,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  @override
  String toString() {
    return 'QuestionRecordsData{total: $total, totalPages: $totalPages, currentPage: $currentPage, questions: $questions}';
  }
}
