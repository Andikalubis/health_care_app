import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }
}
