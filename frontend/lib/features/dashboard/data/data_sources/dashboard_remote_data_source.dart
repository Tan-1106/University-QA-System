import 'package:dio/dio.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/features/dashboard/data/models/dashboard_statistics.dart';
import 'package:university_qa_system/features/dashboard/data/models/dashboard_question_list.dart';

abstract interface class DashboardRemoteDataSource {
  // Fetch statistics data from the server
  Future<DashboardStatisticsModel> getStatistics();

  // Fetch question records from the server with optional pagination and filtering
  Future<DashboardQuestionListModel> getQuestions({
    int page = 1,
    String? feedbackType,
  });

  // Send a response to a specific question
  Future<void> respondToQuestion({
    required String questionId,
    required String adminResponse,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSourceImpl(this._dio);

  // Fetch statistics data from the server
  @override
  Future<DashboardStatisticsModel> getStatistics() async {
    try {
      final response = await _dio.get(
        '/api/statistics/questions-statistics',
        queryParameters: {
          'period_type': 'Monthly',
        },
      );

      final apiResponse = ApiResponse<DashboardStatisticsModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => DashboardStatisticsModel.fromJson(json as Map<String, dynamic>),
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

  // Fetch question records from the server with optional pagination and filtering
  @override
  Future<DashboardQuestionListModel> getQuestions({int page = 1, String? feedbackType}) async {
    try {
      final response = await _dio.get(
        '/api/qa/all',
        queryParameters: {
          'page': page,
          if (feedbackType != null) 'feedback_type': feedbackType,
        },
      );

      final apiResponse = ApiResponse<DashboardQuestionListModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => DashboardQuestionListModel.fromJson(json as Map<String, dynamic>),
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

  // Send a response to a specific question
  @override
  Future<void> respondToQuestion({
    required String questionId,
    required String adminResponse,
  }) async {
    try {
      await _dio.post(
        '/api/qa/$questionId/reply',
        data: {
          'manager_answer': adminResponse,
        },
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    }
  }
}
