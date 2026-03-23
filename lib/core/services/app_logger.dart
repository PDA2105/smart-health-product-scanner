import 'package:flutter/foundation.dart';

/// Lightweight logger that only outputs in debug mode.
class AppLogger {
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('DEBUG: $message');
    }
  }

  static void warn(String message) {
    if (kDebugMode) {
      debugPrint('WARN: $message');
    }
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      debugPrint('ERROR: $message');
      if (error != null) {
        debugPrint('CAUSE: $error');
      }
      if (stackTrace != null) {
        debugPrint('STACK: $stackTrace');
      }
    }
  }
}