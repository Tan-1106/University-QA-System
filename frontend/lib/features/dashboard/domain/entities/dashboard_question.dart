class DashboardQuestionEntity {
  final String id;
  final String userId;
  final String userSub;
  final String question;
  final String? answer;
  final String? feedback;
  final String? managerAnswer;
  final String createdAt;

  DashboardQuestionEntity({
    required this.id,
    required this.userId,
    required this.userSub,
    required this.question,
    this.answer,
    this.feedback,
    this.managerAnswer,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'DashboardQuestionEntity{id: $id, userId: $userId, userSub: $userSub, question: $question, answer: $answer, feedback: $feedback, managerAnswer: $managerAnswer, createdAt: $createdAt}';
  }
}