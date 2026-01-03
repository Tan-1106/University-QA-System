import 'package:dio/dio.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/popular_question/data/models/existing_faculties_data.dart';
import 'package:university_qa_system/features/popular_question/data/models/popular_questions_data.dart';

abstract interface class PopularQuestionDataSource {
  Future<bool> generatePopularQuestions();

  Future<PopularQuestionsData> fetchPopularQuestionsForStudent({
    bool facultyOnly = false,
  });

  Future<PopularQuestionsData> fetchPopularQuestionsForAdmin({
    String? faculty,
    bool isDisplay = true,
  });

  Future<ExistingFacultiesData> fetchFaculties();

  Future<bool> toggleQuestionDisplayStatus(String questionId);

  Future<bool> assignFacultyScopeToQuestions(String faculty);

  Future<bool> updateQuestion(String questionId, String? question, String? answer);
}

class PopularQuestionDataSourceImpl implements PopularQuestionDataSource {
  final Dio _dio;

  PopularQuestionDataSourceImpl(this._dio);

  @override
  Future<bool> generatePopularQuestions() async {
    try {
      final queryParameters = <String, dynamic>{
        'period_type': 'Monthly',
        'n': '20',
      };

      final response = await _dio.get(
        '/api/statistics/generate-popular-questions',
        queryParameters: queryParameters,
      );

      if (response.statusCode != 200) {
        throw const ServerException('Failed to generate potential questions');
      }

      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }

  @override
  Future<PopularQuestionsData> fetchPopularQuestionsForStudent({
    bool facultyOnly = false,
  }) async {
    try {
      // No need to implement pagination because small number of questions
      final queryParameters = <String, dynamic>{
        'page': 1,
        'limit': 10,
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
        throw const ServerException('Failed to retrieve popular questions');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }

  @override
  Future<PopularQuestionsData> fetchPopularQuestionsForAdmin({
    String? faculty,
    bool isDisplay = true,
  }) async {
    try {
      // No need to implement pagination because small number of questions
      final queryParameters = <String, dynamic>{
        'page': 1,
        'limit': 20,
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
        throw const ServerException('Failed to retrieve popular questions');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
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
        throw const ServerException('Failed to retrieve faculties');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }

  @override
  Future<bool> toggleQuestionDisplayStatus(String questionId) async {
    try {
      final response = await _dio.patch(
        '/api/statistics/popular-questions/$questionId/toggle-display',
      );
      if (response.statusCode != 200) {
        throw const ServerException('Failed to toggle question display status');
      }
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }

  @override
  Future<bool> assignFacultyScopeToQuestions(String faculty) async {
    try {
      final queryParameters = <String, dynamic>{
        'faculty': faculty,
      };
      final response = await _dio.post(
        '/api/statistics/popular-questions/assign-faculty',
        queryParameters: queryParameters,
      );
      if (response.statusCode != 200) {
        throw const ServerException('Failed to assign faculty scope to questions');
      }
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }

  @override
  Future<bool> updateQuestion(String questionId, String? question, String? answer) async {
    try {
      final body = <String, dynamic>{
        if (question != null) 'question': question,
        if (answer != null) 'answer': answer,
      };
      final response = await _dio.put(
        '/api/statistics/popular-questions/$questionId/update',
        data: body,
      );
      if (response.statusCode != 200) {
        throw const ServerException('Failed to update question');
      }
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }
}
