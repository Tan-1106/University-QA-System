import 'package:dio/dio.dart';
import 'package:university_qa_system/features/popular_question/data/models/existing_faculties_data.dart';
import 'package:university_qa_system/features/popular_question/data/models/popular_questions_data.dart';

import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/existing_faculties.dart';

abstract interface class PopularQuestionDataSource {
  Future<PopularQuestionsData> fetchPopularQuestionsForStudent({
    int page = 1,
    bool facultyOnly = false,
  });

  Future<PopularQuestionsData> fetchPopularQuestionsForAdmin({
    int page = 1,
    bool isDisplay = true,
    String? faculty,
  });

  Future<ExistingFacultiesData> fetchFaculties();
}

class PopularQuestionDataSourceImpl implements PopularQuestionDataSource {
  final Dio _dio;

  PopularQuestionDataSourceImpl(this._dio);

  @override
  Future<PopularQuestionsData> fetchPopularQuestionsForStudent({int page = 1, bool facultyOnly = false}) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'faculty_only': facultyOnly,
      };

      final response = await _dio.get(
        '/api/statistics/popular-questions-student',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final details = data['details'] as Map<String, dynamic>;
        return PopularQuestionsData.fromJson(details);
      } else {
        throw ServerException('Failed to retrieve popular questions');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error');
      }
    }
  }

  @override
  Future<PopularQuestionsData> fetchPopularQuestionsForAdmin({
    int page = 1,
    bool isDisplay = true,
    String? faculty,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'is_display': isDisplay,
        if (faculty != null) 'faculty': faculty,
      };

      final response = await _dio.get(
        '/api/statistics/popular-questions',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final details = data['details'] as Map<String, dynamic>;
        return PopularQuestionsData.fromJson(details);
      } else {
        throw ServerException('Failed to retrieve popular questions');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error');
      }
    }
  }

  @override
  Future<ExistingFacultiesData> fetchFaculties() async {
    try {
      final response = await _dio.get('/api/users/faculties');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final details = data['details'] as Map<String, dynamic>;
        return ExistingFacultiesData.fromJson(details);
      } else {
        throw ServerException('Failed to retrieve faculties');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw ServerException('Network Error');
      }
    }
  }
}
