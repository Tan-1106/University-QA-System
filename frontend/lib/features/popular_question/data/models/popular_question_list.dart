import 'package:university_qa_system/features/popular_question/data/models/popular_question.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_question_list.dart';

class PopularQuestionListModel {
  final List<PopularQuestionModel> popularQuestions;
  final int total;
  final int totalPages;
  final int currentPage;

  PopularQuestionListModel({
    required this.popularQuestions,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory PopularQuestionListModel.fromJson(Map<String, dynamic> json) {
    var popularQuestionsJson = json['popular_questions'] as List<dynamic>;
    List<PopularQuestionModel> popularQuestionsList = popularQuestionsJson
        .map(
          (pqJson) => PopularQuestionModel(
            id: pqJson['id'] as String,
            question: pqJson['question'] as String,
            answer: pqJson['answer'] as String,
            summary: SummaryModel(
              facultyScope: pqJson['summary']?['faculty_scope'] as String?,
              startDate: pqJson['summary']?['start_date'] as String?,
              endDate: pqJson['summary']?['end_date'] as String?,
              count: pqJson['summary']?['count'] as int? ?? 0,
            ),
            isDisplay: pqJson['is_display'] as bool,
            createdAt: pqJson['created_at'] as String,
            updatedAt: pqJson['updated_at'] as String?,
          ),
        )
        .toList();

    return PopularQuestionListModel(
      popularQuestions: popularQuestionsList,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }

  PopularQuestionListEntity toEntity() {
    return PopularQuestionListEntity(
      popularQuestions: popularQuestions
          .map((pqModel) => pqModel.toEntity())
          .toList(),
      total: total,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  @override
  String toString() {
    return 'PopularQuestionsData{total: $total, totalPages: $totalPages, currentPage: $currentPage, popularQuestions: $popularQuestions}';
  }
}
