class QuestionEntity {
  final String questionID;
  final String question;
  final String? answer;

  QuestionEntity({
    required this.questionID,
    required this.question,
    this.answer,
  });

  @override
  String toString() {
    return 'QARecordEntity{questionID: $questionID, question: $question, answer: $answer}';
  }
}