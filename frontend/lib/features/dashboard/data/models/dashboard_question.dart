import 'package:university_qa_system/features/dashboard/domain/entities/dashboard_question.dart';

class DashboardQuestionModel {
  final String id;
  final String userId;
  final String userSub;
  final String question;
  final String? answer;
  final String? feedback;
  final String? managerAnswer;
  final String createdAt;

  DashboardQuestionModel({
    required this.id,
    required this.userId,
    required this.userSub,
    required this.question,
    this.answer,
    this.feedback,
    this.managerAnswer,
    required this.createdAt,
  });

  factory DashboardQuestionModel.fromJson(Map<String, dynamic> json) {
    return DashboardQuestionModel(
      id: json['_id'] as String,
      userId: json['user_id'] as String,
      userSub: json['user_sub'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String?,
      feedback: json['feedback'] as String?,
      managerAnswer: json['manager_answer'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  DashboardQuestionEntity toEntity() {
    return DashboardQuestionEntity(
      id: id,
      userId: userId,
      userSub: userSub,
      question: question,
      answer: answer,
      feedback: feedback,
      managerAnswer: managerAnswer,
      createdAt: createdAt,
    );
  }
}