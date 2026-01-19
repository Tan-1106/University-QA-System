import 'package:university_qa_system/features/chat/domain/entities/question_details.dart';

class QuestionDetailsModel {
  final String id;
  final String question;
  final String answer;
  final String? feedback;
  final String? managerAnswer;

  const QuestionDetailsModel({
    required this.id,
    required this.question,
    required this.answer,
    this.feedback,
    this.managerAnswer,
  });

  factory QuestionDetailsModel.fromJson(Map<String, dynamic> json) {
    return QuestionDetailsModel(
      id: json['_id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      feedback: json['feedback'] as String?,
      managerAnswer: json['manager_answer'] as String?,
    );
  }

  QuestionDetailsEntity toEntity() {
    return QuestionDetailsEntity(
      id: id,
      question: question,
      answer: answer,
      feedback: feedback,
      managerAnswer: managerAnswer,
    );
  }

  @override
  String toString() {
    return 'QaRecordDetailsData(id: $id, question: $question, answer: $answer, feedback: $feedback, managerAnswer: $managerAnswer)';
  }
}