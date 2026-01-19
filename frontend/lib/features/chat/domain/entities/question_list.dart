import 'package:university_qa_system/features/chat/domain/entities/question.dart';

class QuestionListEntity {
  final List<QuestionEntity> questions;
  final int total;
  final int totalPages;
  final int currentPage;

  const QuestionListEntity({
    required this.questions,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  String toString() {
    return 'QAHistory(questions: $questions, total: $total, totalPages: $totalPages, currentPage: $currentPage)';
  }
}