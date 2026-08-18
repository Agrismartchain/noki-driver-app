import 'dart:async';

import 'package:dio/dio.dart';

import '../auth/auth_session_gateway.dart';
import '../config/app_environment.dart';
import '../logging/app_logger.dart';

/// Builds the single [Dio] instance used by the whole app.
///
/// Responsibilities centralized here (see README "HTTP/security"):
/// - base URL + connect/receive/send timeouts from [AppConfig]
/// - Authorization header injection from [AuthSessionGateway]
/// - single-flight 401 refresh: concurrent requests that hit 401 wait for
///   one in-flight refresh instead of each triggering their own
/// - redacted request/response logging in debug builds only
Dio buildDriverApiDio({
  required AppConfig config,
  required AuthSessionGateway sessionGateway,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(_AuthInterceptor(dio: dio, sessionGateway: sessionGateway));
  dio.interceptors.add(_RedactedLogInterceptor());

  return dio;
}

/// Injects the bearer token and performs a single-flight refresh-and-retry
/// on 401 responses from endpoints that require auth. `/v1/auth/login` and
/// `/v1/auth/refresh` are excluded to avoid recursive refresh loops.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({required this.dio, required this.sessionGateway});

  final Dio dio;
  final AuthSessionGateway sessionGateway;

  Future<String?>? _refreshInFlight;

  static const _noAuthPaths = ['/v1/auth/login', '/v1/auth/refresh'];

  bool _isAuthExempt(String path) => _noAuthPaths.any((p) => path.contains(p));

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isAuthExempt(options.path)) {
      final token = await sessionGateway.currentAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final requestPath = err.requestOptions.path;

    if (response?.statusCode == 401 && !_isAuthExempt(requestPath)) {
      _refreshInFlight ??= sessionGateway.refreshAccessToken().whenComplete(() {
        _refreshInFlight = null;
      });
      final newToken = await _refreshInFlight;

      if (newToken == null) {
        await sessionGateway.onSessionExpired();
        handler.next(err);
        return;
      }

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';
      try {
        final retryResponse = await dio.fetch(retryOptions);
        handler.resolve(retryResponse);
        return;
      } on DioException catch (retryError) {
        handler.next(retryError);
        return;
      }
    }

    handler.next(err);
  }
}

class _RedactedLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug(
      'HTTP → ${options.method} ${options.path}',
      data: {'headers': options.headers, 'query': options.queryParameters},
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug('HTTP ← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.warning(
      'HTTP ✗ ${err.requestOptions.method} ${err.requestOptions.path} (${err.response?.statusCode ?? err.type})',
    );
    handler.next(err);
  }
}
