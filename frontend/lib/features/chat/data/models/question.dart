import 'package:university_qa_system/features/chat/domain/entities/question.dart';

class QuestionModel {
  final String questionID;
  final String question;
  final String? answer;

  QuestionModel({
    required this.questionID,
    required this.question,
    this.answer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      questionID: json['question_id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String?,
    );
  }

  QuestionEntity toEntity() {
    return QuestionEntity(
      questionID: questionID,
      question: question,
      answer: answer,
    );
  }

  @override
  String toString() {
    return 'QAData{questionID: $questionID, question: $question, answer: $answer}';
  }
}