import 'package:university_qa_system/features/dashboard/domain/entities/dashboard_question.dart';

class DashboardQuestionListEntity {
  final List<DashboardQuestionEntity> questions;
  final int total;
  final int totalPages;
  final int currentPage;

  DashboardQuestionListEntity({
    required this.questions,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  String toString() {
    return 'DashboardQuestionListEntity{total: $total, totalPages: $totalPages, currentPage: $currentPage, questions: $questions}';
  }
}


