import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_care_app/features/auth/data/models/auth_response.dart';
import 'package:health_care_app/core/network/base_api.dart';

mixin AuthApi on BaseApi {
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(unwrap(response));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', authResponse.accessToken);
        await prefs.setString('user_name', authResponse.user.name);
        await prefs.setInt('user_id', authResponse.user.id);
        await prefs.setString('user_email', authResponse.user.email);
        await prefs.setString('user_role', authResponse.user.role);
        if (authResponse.refreshToken != null) {
          await prefs.setString('refresh_token', authResponse.refreshToken!);
        }
        return authResponse;
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      handleError(e, 'Login failed');
    }
  }

  Future<AuthResponse> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(unwrap(response));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', authResponse.accessToken);
        await prefs.setString('user_name', authResponse.user.name);
        await prefs.setInt('user_id', authResponse.user.id);
        await prefs.setString('user_email', authResponse.user.email);
        await prefs.setString('user_role', authResponse.user.role);
        if (authResponse.refreshToken != null) {
          await prefs.setString('refresh_token', authResponse.refreshToken!);
        }
        return authResponse;
      } else {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      handleError(e, 'Registration failed');
    }
  }

  Future<void> logout() async {
    try {
      await dio.post('/logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }
}
