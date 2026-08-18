import 'package:dio/dio.dart';

/// Central, transport-agnostic application error model.
///
/// Every repository maps its raw exceptions (Dio, storage, parsing) into one
/// of these so the UI layer never has to interpret an HTTP status code or a
/// platform exception directly.
enum AppFailureType {
  network,
  timeout,
  unauthenticated,
  forbidden,
  notFound,
  validation,
  conflict,
  rateLimited,
  server,
  unknown,
}

class AppFailure implements Exception {
  const AppFailure(this.type, {this.message, this.statusCode, this.fieldErrors});

  final AppFailureType type;

  /// Backend-provided message when safe to show (never raw stack traces).
  final String? message;
  final int? statusCode;

  /// Field-level validation errors (422), keyed by field name.
  final Map<String, List<String>>? fieldErrors;

  static AppFailure fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppFailure(AppFailureType.timeout);
      case DioExceptionType.connectionError:
        return const AppFailure(AppFailureType.network);
      case DioExceptionType.cancel:
        return const AppFailure(AppFailureType.unknown, message: 'cancelled');
      case DioExceptionType.badResponse:
        return _fromStatusCode(e.response?.statusCode, e.response?.data);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      default:
        return const AppFailure(AppFailureType.network);
    }
  }

  static AppFailure _fromStatusCode(int? statusCode, dynamic data) {
    final message = _extractMessage(data);
    switch (statusCode) {
      case 401:
        return AppFailure(AppFailureType.unauthenticated, message: message, statusCode: statusCode);
      case 403:
        return AppFailure(AppFailureType.forbidden, message: message, statusCode: statusCode);
      case 404:
        // Deliberately non-enumerating: never distinguish "does not exist"
        // from "not yours to see" in the message shown to the driver.
        return AppFailure(AppFailureType.notFound, message: message, statusCode: statusCode);
      case 409:
        return AppFailure(AppFailureType.conflict, message: message, statusCode: statusCode);
      case 422:
        return AppFailure(
          AppFailureType.validation,
          message: message,
          statusCode: statusCode,
          fieldErrors: _extractFieldErrors(data),
        );
      case 429:
        return AppFailure(AppFailureType.rateLimited, message: message, statusCode: statusCode);
      default:
        if (statusCode != null && statusCode >= 500) {
          return AppFailure(AppFailureType.server, message: message, statusCode: statusCode);
        }
        return AppFailure(AppFailureType.unknown, message: message, statusCode: statusCode);
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map && data['message'] is String) return data['message'] as String;
    if (data is Map && data['message'] is List && data['message'].isNotEmpty) {
      return data['message'].first.toString();
    }
    return null;
  }

  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is Map && data['errors'] is Map) {
      final raw = data['errors'] as Map;
      return raw.map((key, value) => MapEntry(key.toString(), (value as List).map((e) => e.toString()).toList()));
    }
    return null;
  }
}
