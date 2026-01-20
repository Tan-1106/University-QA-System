import 'package:university_qa_system/features/popular_question/domain/entities/popular_question.dart';

class PopularQuestionModel {
  final String id;
  final String question;
  final String answer;
  final SummaryModel summary;
  final bool isDisplay;
  final String createdAt;
  final String? updatedAt;

  PopularQuestionModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.summary,
    required this.isDisplay,
    required this.createdAt,
    this.updatedAt,
  });

  PopularQuestionEntity toEntity() {
    return PopularQuestionEntity(
      id: id,
      question: question,
      answer: answer,
      summary: summary.toEntity(),
      isDisplay: isDisplay,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class SummaryModel {
  final String? facultyScope;
  final String? startDate;
  final String? endDate;
  final int count;

  SummaryModel({
    this.facultyScope,
    this.startDate,
    this.endDate,
    required this.count,
  });

  SummaryEntity toEntity() {
    return SummaryEntity(
      facultyScope: facultyScope,
      startDate: startDate,
      endDate: endDate,
      count: count,
    );
  }
}