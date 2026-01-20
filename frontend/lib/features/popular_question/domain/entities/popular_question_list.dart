import 'package:university_qa_system/features/popular_question/domain/entities/popular_question.dart';

class PopularQuestionListEntity {
  final List<PopularQuestionEntity> popularQuestions;
  final int total;
  final int totalPages;
  final int currentPage;

  PopularQuestionListEntity({
    required this.popularQuestions,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  String toString() {
    return 'PopularQuestionListEntity{total: $total, totalPages: $totalPages, currentPage: $currentPage, popularQuestions: $popularQuestions}';
  }
}
