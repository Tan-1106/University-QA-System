import 'package:dio/dio.dart';
import 'package:university_qa_system/core/services/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService secureStorageService;

  AuthInterceptor({
    required this.dio,
    required this.secureStorageService,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.path.contains('/api/auth/refresh')) {
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      final message = err.response?.data['details'];

      if (message == "Access token has expired") {
        try {
          final isRefreshed = await _refreshToken();

          if (isRefreshed) {
            final newToken = await secureStorageService.getAccessToken();
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            final response = await dio.fetch(options);
            return handler.resolve(response);
          }
        } catch (e) {
          return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await secureStorageService.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        '/api/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final details = response.data['details'];
        final newAt = details['access_token'];
        final newRt = details['refresh_token'];

        await secureStorageService.saveTokens(newAt, newRt);
        return true;
      }
    } catch (e) {
      await secureStorageService.deleteAll();
      return false;
    }
    return false;
  }
}
