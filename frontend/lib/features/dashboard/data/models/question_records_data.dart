import 'package:university_qa_system/features/dashboard/domain/entities/question_records.dart';

class QuestionRecordsData {
  final List<Questions> questions;
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
    List<Questions> recordsList = recordsJson
        .map(
          (recordJson) => Questions(
            id: recordJson['_id'] as String,
            userId: recordJson['user_id'] as String,
            userSub: recordJson['user_sub'] as String,
            userFaculty: recordJson['user_faculty'] as String,
            question: recordJson['question'] as String,
            answer: recordJson['answer'] as String,
            feedback: recordJson['feedback'] as String,
            managerAnswer: recordJson['manager_answer'] as String?,
            createdAt: recordJson['created_at'] as String,
            updatedAt: recordJson['updated_at'] as String,
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

class Questions {
  final String id;
  final String userId;
  final String userSub;
  final String userFaculty;
  final String question;
  final String answer;
  final String feedback;
  final String? managerAnswer;
  final String createdAt;
  final String updatedAt;

  Questions({
    required this.id,
    required this.userId,
    required this.userSub,
    required this.userFaculty,
    required this.question,
    required this.answer,
    required this.feedback,
    this.managerAnswer,
    required this.createdAt,
    required this.updatedAt,
  });
}
