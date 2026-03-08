import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_care_app/features/auth/data/models/auth_response.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;

  TokenInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        return handler.next(err);
      }

      try {
        final result = await _refreshToken(refreshToken);

        await prefs.setString('access_token', result.accessToken);
        if (result.refreshToken != null) {
          await prefs.setString('refresh_token', result.refreshToken!);
        }

        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer ${result.accessToken}';

        final retryDio = Dio(
          BaseOptions(
            baseUrl: options.baseUrl,
            connectTimeout: options.connectTimeout,
            receiveTimeout: options.receiveTimeout,
          ),
        );

        final response = await retryDio.fetch(options);
        return handler.resolve(response);
      } catch (e) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  Future<AuthResponse> _refreshToken(String currentRefreshToken) async {
    final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));

    final response = await refreshDio.post(
      '/refresh',
      data: {'refresh_token': currentRefreshToken},
      options: Options(headers: {'Accept': 'application/json'}),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}
