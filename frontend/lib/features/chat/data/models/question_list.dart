import 'package:university_qa_system/features/chat/data/models/question.dart';
import 'package:university_qa_system/features/chat/domain/entities/question_list.dart';

class QuestionListModel {
  final List<QuestionModel> questions;
  final int total;
  final int totalPages;
  final int currentPage;

  const QuestionListModel({
    required this.questions,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory QuestionListModel.fromJson(Map<String, dynamic> json) {
    var recordsJson = json['questions'] as List<dynamic>;
    List<QuestionModel> recordsList = recordsJson
        .map(
          (recordJson) => QuestionModel(
            questionID: recordJson['_id'] as String,
            question: recordJson['question'] as String,

          ),
        )
        .toList();

    return QuestionListModel(
      questions: recordsList,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }

  QuestionListEntity toEntity() {
    return QuestionListEntity(
      questions: questions.map((q) => q.toEntity()).toList(),
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

