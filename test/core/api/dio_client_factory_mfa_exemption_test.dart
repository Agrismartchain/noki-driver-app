import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/dio_client_factory.dart';
import 'package:noki_driver_app/core/auth/auth_session_gateway.dart';
import 'package:noki_driver_app/core/config/app_environment.dart';

/// Proves the fix in `dio_client_factory.dart`'s `_noAuthPaths`: a 401 from
/// a pre-session MFA challenge endpoint (invalid code, expired challenge -
/// both legitimate, retryable-by-the-user outcomes) must never be treated
/// like an expired *session* - it must never call
/// `sessionGateway.refreshAccessToken()`/`onSessionExpired()`. Before that
/// fix, any 401 from these endpoints (there is no refresh token yet - the
/// driver hasn't signed in) would have gone through
/// `onSessionExpired()` -> wiping whatever in-progress MFA state the
/// feature layer was holding, immediately after a wrong code.
///
/// Built through the real `buildDriverApiDio` (interceptors included) with
/// only the HTTP transport swapped, the same approach as
/// `auth_controller_real_provider_graph_test.dart`.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handler(options);

  @override
  void close({bool force = false}) {}
}

class _RecordingSessionGateway implements AuthSessionGateway {
  int refreshAccessTokenCallCount = 0;
  int onSessionExpiredCallCount = 0;

  @override
  Future<String?> currentAccessToken() async => 'cached-access-token';

  @override
  Future<String?> refreshAccessToken() async {
    refreshAccessTokenCallCount++;
    return null;
  }

  @override
  Future<void> onSessionExpired() async {
    onSessionExpiredCallCount++;
  }
}

ResponseBody _json401(Map<String, dynamic> body) {
  return ResponseBody.fromBytes(
    utf8.encode(jsonEncode(body)),
    401,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  test(
    'a 401 from an MFA challenge endpoint never triggers refresh/session-expired',
    () async {
      final gateway = _RecordingSessionGateway();
      final dio = buildDriverApiDio(
        config: AppConfig.fromValues(envRaw: 'development', apiBaseUrlRaw: 'http://unit-test.invalid'),
        sessionGateway: gateway,
      );
      dio.httpClientAdapter = _FakeHttpClientAdapter(
        (options) async => _json401({'code': 'MFA_CODE_INVALID', 'message': 'The code is not valid'}),
      );

      await expectLater(
        dio.post('/v1/auth/mfa/challenge/verify', data: {'challengeToken': 't', 'code': '000000'}),
        throwsA(isA<DioException>()),
      );

      expect(gateway.refreshAccessTokenCallCount, 0);
      expect(gateway.onSessionExpiredCallCount, 0);
    },
  );

  test(
    'a 401 from a real authenticated endpoint still triggers the refresh flow (regression guard)',
    () async {
      final gateway = _RecordingSessionGateway();
      final dio = buildDriverApiDio(
        config: AppConfig.fromValues(envRaw: 'development', apiBaseUrlRaw: 'http://unit-test.invalid'),
        sessionGateway: gateway,
      );
      dio.httpClientAdapter = _FakeHttpClientAdapter(
        (options) async => _json401({'message': 'Unauthorized'}),
      );

      await expectLater(
        dio.get('/v1/driver/context'),
        throwsA(isA<DioException>()),
      );

      // Confirms the exemption list added for MFA is narrow, not a blanket
      // "never refresh on 401" change: an unrelated authenticated endpoint
      // still goes through the existing refresh-then-retry path exactly as
      // before.
      expect(gateway.refreshAccessTokenCallCount, 1);
      expect(gateway.onSessionExpiredCallCount, 1);
    },
  );
}
