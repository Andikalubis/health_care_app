import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_care_app/features/auth/data/models/auth_response.dart';
import 'package:health_care_app/features/auth/data/token_interceptor.dart';
import 'package:chucker_flutter/chucker_flutter.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://192.168.112.146:8000/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  ApiService() {
    _dio.interceptors.addAll([ChuckerDioInterceptor(), TokenInterceptor(_dio)]);
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
        final data = e.response?.data;

        String message = 'Operation failed';

        if (data is Map) {
          message = data['message'] ?? message;
        } else if (data is String) {
          message = data;
        }

        throw Exception(message);
      }

      rethrow;
    }
  }

  Future<AuthResponse> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', authResponse.accessToken);
        await prefs.setString('user_name', authResponse.user.name);

        if (authResponse.refreshToken != null) {
          await prefs.setString('refresh_token', authResponse.refreshToken!);
        }

        return authResponse;
      } else {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;

        String message = 'Registration failed';

        if (data is Map) {
          message = data['message'] ?? message;
        } else if (data is String) {
          message = data;
        }

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
