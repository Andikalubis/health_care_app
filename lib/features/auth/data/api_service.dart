import 'package:dio/dio.dart';
import 'package:health_care_app/features/auth/data/models/auth_response.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.10.90.20:8000/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'] ?? 'Login failed';
        throw Exception(message);
      }
      rethrow;
    }
  }

  Future<AuthResponse> refreshToken(String currentToken) async {
    try {
      final response = await _dio.post(
        '/refresh',
        options: Options(headers: {'Authorization': 'Bearer $currentToken'}),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to refresh token: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message =
            e.response?.data['message'] ?? 'Failed to refresh token';
        throw Exception(message);
      }
      rethrow;
    }
  }
}
