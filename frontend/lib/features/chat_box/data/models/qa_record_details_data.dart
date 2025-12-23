import 'package:university_qa_system/features/chat_box/domain/entities/qa_record_details.dart';

class QARecordDetailsData {
  final String id;
  final String question;
  final String answer;
  final String? feedback;
  final String? managerAnswer;

  const QARecordDetailsData({
    required this.id,
    required this.question,
    required this.answer,
    this.feedback,
    this.managerAnswer,
  });

  factory QARecordDetailsData.fromJson(Map<String, dynamic> json) {
    return QARecordDetailsData(
      id: json['_id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      feedback: json['feedback'] as String?,
      managerAnswer: json['manager_answer'] as String?,
    );
  }

  QARecordDetails toEntity() {
    return QARecordDetails(
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