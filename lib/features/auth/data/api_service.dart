import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_care_app/features/auth/data/models/auth_response.dart';
import 'package:health_care_app/features/auth/data/token_interceptor.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.10.90.20:8000/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  ApiService() {
    _dio.interceptors.add(TokenInterceptor(_dio));
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', authResponse.accessToken);
        await prefs.setString('user_name', authResponse.user.name);
        if (authResponse.refreshToken != null) {
          await prefs.setString('refresh_token', authResponse.refreshToken!);
        }
        return authResponse;
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_name');
  }
}
