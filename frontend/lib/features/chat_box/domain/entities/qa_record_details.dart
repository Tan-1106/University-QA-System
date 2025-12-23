class QARecordDetails {
  final String id;
  final String question;
  final String answer;
  final String? feedback;
  final String? managerAnswer;

  QARecordDetails({
    required this.id,
    required this.question,
    required this.answer,
    this.feedback,
    this.managerAnswer,
  });
}