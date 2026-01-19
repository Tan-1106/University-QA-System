import 'package:dio/dio.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/features/chat/data/models/question.dart';
import 'package:university_qa_system/features/chat/data/models/question_list.dart';
import 'package:university_qa_system/features/chat/data/models/question_details.dart';

abstract interface class ChatRemoteDataSource {
  // Ask a question and get an answer
  Future<QuestionModel> askQuestion({
    required String question,
  });

  // Send a feedback
  Future<void> sendFeedback({
    required String questionID,
    required String feedback,
  });

  // Get user Q&A history
  Future<QuestionListModel> getQuestionHistory({
    required int page,
  });

  // Get details of a specific question
  Future<QuestionDetailsModel> getQuestionDetails({
    required String questionID,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSourceImpl(this._dio);

  // Ask a question and get an answer
  @override
  Future<QuestionModel> askQuestion({
    required String question,
  }) async {
    try {
      final response = await _dio.post(
        '/api/qa/ask',
        data: {'question': question},
      );

      final apiResponse = ApiResponse<QuestionModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => QuestionModel.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.details!;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Send a feedback
  @override
  Future<void> sendFeedback({
    required String questionID,
    required String feedback,
  }) async {
    try {
      await _dio.post(
        '/api/qa/feedback/$questionID',
        data: {'feedback': feedback},
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Get user Q&A history
  @override
  Future<QuestionListModel> getQuestionHistory({
    required int page,
  }) async {
    try {
      final response = await _dio.get(
        '/api/qa/history',
        queryParameters: {'page': page},
      );

      final apiResponse = ApiResponse<QuestionListModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => QuestionListModel.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.details!;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }

  // Get details of a specific question
  @override
  Future<QuestionDetailsModel> getQuestionDetails({
    required String questionID,
  }) async {
    try {
      final response = await _dio.get(
        '/api/qa/$questionID',
      );

      final apiResponse = ApiResponse<QuestionDetailsModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => QuestionDetailsModel.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.details!;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }
}
