import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:health_care_app/core/network/error_interceptor.dart';
import 'package:health_care_app/features/auth/data/token_interceptor.dart';

abstract class BaseApi {
  late final Dio dio;

  BaseApi() {
    dio = Dio(
      BaseOptions(
        baseUrl:
            dotenv.env['API_BASE_URL'] ?? 'http://192.168.112.146:8000/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.addAll([
      ChuckerDioInterceptor(),
      TokenInterceptor(dio),
      ErrorInterceptor(),
    ]);
  }

  // ─── Helpers ───────────────────────────────────────────────
  dynamic unwrap(Response res) {
    if (res.data is Map && res.data.containsKey('data')) {
      return res.data['data'];
    }
    return res.data;
  }

  Never handleError(DioException e, String fallback) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      String message = fallback;
      if (data is Map) {
        message = data['message'] ?? fallback;
      } else if (data is String) {
        message = data;
      }
      throw Exception(message);
    }
    throw e;
  }
}
