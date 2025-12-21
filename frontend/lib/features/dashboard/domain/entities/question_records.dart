import 'package:university_qa_system/features/dashboard/data/models/question_records_data.dart';

class QuestionRecords {
  final List<Questions> questions;
  final int total;
  final int totalPages;
  final int currentPage;

  QuestionRecords({
    required this.questions,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });
}