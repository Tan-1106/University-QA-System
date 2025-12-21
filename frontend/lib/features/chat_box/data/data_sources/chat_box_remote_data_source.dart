import 'package:dio/dio.dart';
import 'package:university_qa_system/core/error/exceptions.dart';
import 'package:university_qa_system/core/common/api_response.dart';
import 'package:university_qa_system/features/chat_box/data/models/qa_data.dart';



abstract interface class ChatBoxRemoteDataSource {
  Future<QAData> askQuestion({
    required String question,
  });
}

class ChatBoxRemoteDataSourceImpl implements ChatBoxRemoteDataSource {
  final Dio _dio;

  ChatBoxRemoteDataSourceImpl(this._dio);

  @override
  Future<QAData> askQuestion({required String question}) async {
    try {
      final response = await _dio.post(
        '/api/qa/ask',
        data: {'question': question},
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<QAData>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => QAData.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.details != null) {
          return apiResponse.details!;
        } else {
          throw ServerException('QA data is missing in the response');
        }
      } else {
        throw ServerException('Failed to retrieve QA data');
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