import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_care_app/core/network/error_interceptor.dart';
import 'package:health_care_app/core/utils/logger.dart';
import 'package:health_care_app/features/auth/data/token_interceptor.dart';
import 'package:flutter/foundation.dart';

class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;
  const _CacheEntry(this.data, this.expiresAt);
}

abstract class BaseApi {
  late final Dio dio;
  final Map<String, _CacheEntry> _cache = {};
  static const Duration _cacheTtl = Duration(seconds: 30);

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
      TokenInterceptor(dio),
      ErrorInterceptor(),
    ]);

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: false,
          requestHeader: true,
          requestBody: false,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => Log.api('Dio', obj.toString()),
        ),
      );
    }
  }

  Future<T> cachedGet<T>(String key, Future<T> Function() fetch) async {
    final now = DateTime.now();
    final entry = _cache[key];
    if (entry != null && now.isBefore(entry.expiresAt)) {
      final remaining = entry.expiresAt.difference(now).inSeconds;
      Log.cache('HIT  $key (TTL: ${remaining}s remaining)');
      return entry.data as T;
    }

    final stopwatch = Stopwatch()..start();
    final data = await fetch();
    stopwatch.stop();
    _cache[key] = _CacheEntry(data, now.add(_cacheTtl));
    Log.cache('MISS $key (fetched in ${stopwatch.elapsedMilliseconds}ms)');
    return data;
  }

  void invalidateCache([String? key]) {
    if (key != null) {
      _cache.remove(key);
      Log.cache('INVALIDATE $key');
    } else {
      _cache.clear();
      Log.cache('INVALIDATE ALL');
    }
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
      final statusCode = e.response?.statusCode;
      String message = fallback;

      if (statusCode != null) {
        Log.api('HTTP', '$statusCode ${e.requestOptions.method} ${e.requestOptions.path}');
      }

      if (data is Map) {
        if (statusCode == 422 && data.containsKey('errors')) {
          final errors = data['errors'] as Map?;
          if (errors != null && errors.isNotEmpty) {
            final parts = <String>[];
            for (final entry in errors.entries) {
              final field = entry.key;
              final msgs = entry.value;
              if (msgs is List) {
                for (final m in msgs) {
                  parts.add('$field: $m');
                }
              } else if (msgs is String) {
                parts.add('$field: $msgs');
              }
            }
            if (parts.isNotEmpty) {
              message = parts.join('\n');
            } else {
              message = data['message'] ?? fallback;
            }
          } else {
            message = data['message'] ?? fallback;
          }
        } else {
          message = data['message'] ?? fallback;
        }
      } else if (data is String) {
        message = data;
      }

      throw Exception(message);
    }
    throw e;
  }

  Future<T> safeApiCall<T>(Future<T> Function() call, String fallback) async {
    try {
      return await call();
    } on DioException catch (e) {
      handleError(e, fallback);
    }
  }
}