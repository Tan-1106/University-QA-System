import 'package:university_qa_system/features/chat_box/domain/entities/qa_record.dart';

class QAData {
  final String questionID;
  final String question;
  final String answer;

  QAData({
    required this.questionID,
    required this.question,
    required this.answer,
  });

  factory QAData.fromJson(Map<String, dynamic> json) {
    return QAData(
      questionID: json['question_id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  QaRecord toEntity() {
    return QaRecord(
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