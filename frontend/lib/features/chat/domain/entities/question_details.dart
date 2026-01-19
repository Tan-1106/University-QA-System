class QuestionDetailsEntity {
  final String id;
  final String question;
  final String answer;
  final String? feedback;
  final String? managerAnswer;

  QuestionDetailsEntity({
    required this.id,
    required this.question,
    required this.answer,
    this.feedback,
    this.managerAnswer,
  });

  @override
  String toString() {
    return 'QARecordDetailsEntity{id: $id, question: $question, answer: $answer, feedback: $feedback, managerAnswer: $managerAnswer}';
  }
}