import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:health_care_app/features/error/presentation/pages/not_found_page.dart';
import 'package:health_care_app/features/error/presentation/pages/server_error_page.dart';
import 'package:health_care_app/main.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      final statusCode = err.response?.statusCode;

      if (statusCode == 404) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NotFoundPage()),
        );
      } else if (statusCode != null && statusCode >= 500) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const ServerErrorPage()),
        );
      }
    }
    return handler.next(err);
  }
}
