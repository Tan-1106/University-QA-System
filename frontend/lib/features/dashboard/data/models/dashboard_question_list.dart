import 'package:university_qa_system/features/dashboard/data/models/dashboard_question.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/dashboard_question_list.dart';

class DashboardQuestionListModel {
  final List<DashboardQuestionModel> questions;
  final int total;
  final int totalPages;
  final int currentPage;

  DashboardQuestionListModel({
    required this.questions,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory DashboardQuestionListModel.fromJson(Map<String, dynamic> json) {
    var recordsJson = json['questions'] as List<dynamic>;
    List<DashboardQuestionModel> recordsList = recordsJson
        .map(
          (recordJson) => DashboardQuestionModel(
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

    return DashboardQuestionListModel(
      questions: recordsList,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }

  DashboardQuestionListEntity toEntity() {
    return DashboardQuestionListEntity(
      questions: questions.map((q) => q.toEntity()).toList(),
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
