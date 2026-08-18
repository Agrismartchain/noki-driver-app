import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';

DioException _response(int statusCode, {dynamic data}) {
  final requestOptions = RequestOptions(path: '/v1/driver/context');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: requestOptions, statusCode: statusCode, data: data),
  );
}

void main() {
  group('AppFailure.fromDioException', () {
    test('maps connect/send/receive timeouts to AppFailureType.timeout', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final failure = AppFailure.fromDioException(
          DioException(requestOptions: RequestOptions(path: '/x'), type: type),
        );
        expect(failure.type, AppFailureType.timeout);
      }
    });

    test('maps connectionError to AppFailureType.network', () {
      final failure = AppFailure.fromDioException(
        DioException(requestOptions: RequestOptions(path: '/x'), type: DioExceptionType.connectionError),
      );
      expect(failure.type, AppFailureType.network);
    });

    test('maps 401 to unauthenticated', () {
      expect(AppFailure.fromDioException(_response(401)).type, AppFailureType.unauthenticated);
    });

    test('maps 403 to forbidden', () {
      expect(AppFailure.fromDioException(_response(403)).type, AppFailureType.forbidden);
    });

    test('maps 404 to notFound without leaking whether it exists vs is forbidden', () {
      final failure = AppFailure.fromDioException(_response(404, data: {'message': 'Not Found'}));
      expect(failure.type, AppFailureType.notFound);
    });

    test('maps 409 to conflict', () {
      expect(AppFailure.fromDioException(_response(409)).type, AppFailureType.conflict);
    });

    test('maps 422 to validation and extracts field errors', () {
      final failure = AppFailure.fromDioException(
        _response(422, data: {
          'message': 'Validation failed',
          'errors': {
            'countryCode': ['must be a supported country code'],
          },
        }),
      );
      expect(failure.type, AppFailureType.validation);
      expect(failure.fieldErrors?['countryCode'], ['must be a supported country code']);
    });

    test('maps 429 to rateLimited', () {
      expect(AppFailure.fromDioException(_response(429)).type, AppFailureType.rateLimited);
    });

    test('maps 5xx to server', () {
      expect(AppFailure.fromDioException(_response(500)).type, AppFailureType.server);
      expect(AppFailure.fromDioException(_response(503)).type, AppFailureType.server);
    });

    test('maps an unmapped status code to unknown', () {
      expect(AppFailure.fromDioException(_response(418)).type, AppFailureType.unknown);
    });

    test('extracts a string message when present', () {
      final failure = AppFailure.fromDioException(_response(400, data: {'message': 'Bad request'}));
      expect(failure.message, 'Bad request');
    });
  });
}
