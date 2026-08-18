import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Keys whose values must never reach a log line, in dev or release.
const List<String> _redactedKeys = [
  'accesstoken',
  'refreshtoken',
  'authorization',
  'password',
  'otp',
  'token',
];

const String _redactedPlaceholder = '<redacted>';

/// Central logger. In release builds only warnings/errors are recorded and
/// their payloads are redacted; in debug builds more technical detail is
/// available but redaction still applies to every known-sensitive key.
class AppLogger {
  const AppLogger._();

  static void debug(String message, {Object? data}) {
    if (!kDebugMode) return;
    _log('DEBUG', message, data);
  }

  static void info(String message, {Object? data}) {
    _log('INFO', message, kDebugMode ? data : null);
  }

  static void warning(String message, {Object? data}) {
    _log('WARN', message, data);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, Object? data}) {
    developer.log(
      '[ERROR] $message',
      name: 'noki_driver_app',
      error: error,
      stackTrace: kDebugMode ? stackTrace : null,
    );
    if (data != null) {
      developer.log('  data: ${redact(data)}', name: 'noki_driver_app');
    }
  }

  static void _log(String level, String message, Object? data) {
    final suffix = data == null ? '' : ' ${redact(data)}';
    developer.log('[$level] $message$suffix', name: 'noki_driver_app');
  }

  /// Recursively redacts any Map key that looks sensitive. Used for HTTP
  /// header/body logging and for any ad-hoc structured log payload.
  static Object? redact(Object? value) {
    if (value is Map) {
      return value.map((key, v) {
        final keyLower = key.toString().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
        final isSensitive = _redactedKeys.any((k) => keyLower.contains(k));
        return MapEntry(key, isSensitive ? _redactedPlaceholder : redact(v));
      });
    }
    if (value is List) {
      return value.map(redact).toList();
    }
    return value;
  }
}
