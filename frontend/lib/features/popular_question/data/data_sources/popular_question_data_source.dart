import 'package:dio/dio.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/features/popular_question/data/models/faculty_list.dart';
import 'package:university_qa_system/features/popular_question/data/models/popular_question_list.dart';

abstract interface class PopularQuestionDataSource {
  // Compile statistics on common questions
  Future<void> generatePopularQuestions();

  // Get popular questions for students
  Future<PopularQuestionListModel> getPopularQuestionsForStudent({
    bool facultyOnly = false,
  });

  // Get popular questions for admin
  Future<PopularQuestionListModel> getPopularQuestionsForAdmin({
    String? faculty,
    bool isDisplay = true,
  });

  // Get list of faculties
  Future<FacultyListModel> getFaculties();

  // Toggle question display status
  Future<void> toggleQuestionDisplayStatus({
    required String questionId,
  });

  // Assign faculty scope to question
  Future<void> assignFacultyScopeToQuestion({
    required String questionId,
    required String? faculty,
  });

  // Update question and/or answer
  Future<void> updateQuestion({
    required String questionId,
    required String? question,
    required String? answer,
  });
}

class PopularQuestionDataSourceImpl implements PopularQuestionDataSource {
  final Dio _dio;

  PopularQuestionDataSourceImpl(this._dio);

  // Compile statistics on common questions
  @override
  Future<void> generatePopularQuestions() async {
    try {
      await _dio.get(
        '/api/statistics/generate-popular-questions',
        queryParameters: {
          'period_type': 'Monthly',
          'n': '20',
        },
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }

  // Get popular questions for students
  @override
  Future<PopularQuestionListModel> getPopularQuestionsForStudent({
    bool facultyOnly = false,
  }) async {
    try {
      final response = await _dio.get(
        '/api/statistics/popular-questions-student',
        queryParameters: {
          'page': 1,
          'limit': 10,
          'faculty_only': facultyOnly,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final details = data['details'] as Map<String, dynamic>;
      return PopularQuestionListModel.fromJson(details);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }

  // Get popular questions for admin
  @override
  Future<PopularQuestionListModel> getPopularQuestionsForAdmin({
    String? faculty,
    bool isDisplay = true,
  }) async {
    try {
      final response = await _dio.get(
        '/api/statistics/popular-questions',
        queryParameters: {
          'page': 1,
          'limit': 20,
          'is_display': isDisplay,
          if (faculty != null) 'faculty': faculty,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final details = data['details'] as Map<String, dynamic>;
      return PopularQuestionListModel.fromJson(details);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }

  // Get list of faculties
  @override
  Future<FacultyListModel> getFaculties() async {
    try {
      final response = await _dio.get(
        '/api/users/faculties',
      );

      final data = response.data as Map<String, dynamic>;
      final details = data['details'] as Map<String, dynamic>;
      return FacultyListModel.fromJson(details);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }

  // Toggle question display status
  @override
  Future<void> toggleQuestionDisplayStatus({
    required String questionId,
  }) async {
    try {
      await _dio.patch(
        '/api/statistics/popular-questions/$questionId/toggle-display',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }

  // Assign faculty scope to question
  @override
  Future<void> assignFacultyScopeToQuestion({
    required String questionId,
    required String? faculty,
  }) async {
    try {
      (faculty != null)
          ? await _dio.patch(
              '/api/statistics/popular-questions/$questionId/assign-faculty',
              data: {'faculty': faculty},
            )
          : await _dio.patch(
              '/api/statistics/popular-questions/$questionId/assign-faculty',
            );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }

  // Update question and/or answer
  @override
  Future<void> updateQuestion({
    required String questionId,
    required String? question,
    required String? answer,
  }) async {
    try {
      await _dio.patch(
        '/api/statistics/popular-questions/$questionId/update',
        data: {
          if (question != null) 'question': question,
          if (answer != null) 'answer': answer,
        },
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Server Error');
      } else {
        throw const ServerException('Network Error');
      }
    }
  }
}
