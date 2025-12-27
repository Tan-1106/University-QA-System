import 'package:dio/dio.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/features/dashboard/data/models/statistic_data.dart';
import 'package:university_qa_system/features/dashboard/data/models/question_records_data.dart';

abstract interface class DashboardRemoteDataSource {
  Future<StatisticData> fetchDashboardStatistic();

  Future<QuestionRecordsData> fetchDashboardQuestionRecords({
    int page = 1,
    String? feedbackType,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSourceImpl(this._dio);

  @override
  Future<StatisticData> fetchDashboardStatistic() async {
    try {
      final response = await _dio.get(
        '/api/statistics/questions-statistics',
        queryParameters: {'period_type': 'Monthly'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<StatisticData>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => StatisticData.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.details != null) {
          return apiResponse.details!;
        } else {
          throw const ServerException('Dashboard data is missing in the response');
        }
      } else {
        throw const ServerException('Failed to retrieve dashboard data');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<QuestionRecordsData> fetchDashboardQuestionRecords({int page = 1, String? feedbackType}) async {
    try {
      final response = await _dio.get(
        '/api/qa/all',
        queryParameters: {
          'page': page,
          if (feedbackType != null) 'feedback_type': feedbackType,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<QuestionRecordsData>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => QuestionRecordsData.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.details != null) {
          return apiResponse.details!;
        } else {
          throw const ServerException('Question records data is missing in the response');
        }
      } else {
        throw const ServerException('Failed to retrieve question records data');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
