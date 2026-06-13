/// Structured logger for organized terminal output.
/// All methods are no-ops in release builds (kDebugMode guard).
library;

import 'package:flutter/foundation.dart';

class Log {
  static void info(String tag, String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('\u2139\ufe0f [$tag] $message');
    }
  }

  static void warn(String tag, String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('\u26a0\ufe0f [$tag] $message');
    }
  }

  static void error(String tag, String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('\u274c [$tag] $message');
    }
  }

  static void api(String tag, String method) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('\u{1f4e1} [$tag] $method');
    }
  }

  static void cache(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('\u{1f4be} [Cache] $message');
    }
  }
}