import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/storage/secure_session_storage.dart';
import 'package:noki_driver_app/core/storage/storage_providers.dart';
import 'package:noki_driver_app/features/auth/auth_providers.dart';
import 'package:noki_driver_app/features/auth/auth_state.dart';

import '../../fixtures/fake_session_storage.dart';

/// Regression coverage for DRIVER-APP-01R4: `AuthController.login()`
/// silently deadlocked - forever, no exception, no timeout, real device
/// only - because resolving `driverApiClientProvider` from inside one of
/// `AuthController`'s own async methods transitively watched
/// `authControllerProvider.notifier` through
/// `driverApiDioProvider -> authSessionGatewayProvider`. Never caught by the
/// existing `auth_controller_test.dart` suite because it overrides
/// `driverApiClientProvider` directly, which breaks that exact chain before
/// it can form - the same blind spot documented for DRIVER-APP-01R3's
/// `CircularDependencyError`.
///
/// This test exercises the REAL provider chain instead: only
/// `driverApiDioProvider`'s HTTP transport is swapped for a canned adapter
/// (the legitimate lowest-level platform/network boundary) - `AppConfig`,
/// `driverApiDioProvider`, `authSessionGatewayProvider` and
/// `driverApiClientProvider` all resolve for real, through the real
/// `AuthController` instance, exactly as production does.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
  final bytes = utf8.encode(jsonEncode(body));
  return ResponseBody.fromBytes(bytes, statusCode, headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  });
}

ProviderContainer _buildRealGraphContainer({
  required Future<ResponseBody> Function(RequestOptions options) httpHandler,
  SecureSessionStorage? storage,
}) {
  final container = ProviderContainer(
    overrides: [
      secureSessionStorageProvider.overrideWithValue(storage ?? FakeSecureSessionStorage()),
      // The only override: swap the real Dio instance's HTTP transport for a
      // canned adapter. driverApiDioProvider, authSessionGatewayProvider and
      // driverApiClientProvider all still build for real.
      driverApiDioProvider.overrideWith((ref) {
        final dio = Dio(BaseOptions(baseUrl: 'http://unit-test.invalid'));
        ref.watch(authSessionGatewayProvider); // wire AuthController in, exactly like the real provider does
        dio.httpClientAdapter = _FakeHttpClientAdapter(httpHandler);
        return dio;
      }),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('login through the real provider graph reaches authenticated with no deadlock', () async {
    final container = _buildRealGraphContainer(
      httpHandler: (options) async {
        if (options.path == '/v1/auth/login') {
          return _jsonResponse({
            'tokenType': 'Bearer',
            'accessToken': 'access-1',
            'accessTokenExpiresIn': 900,
            'refreshToken': 'refresh-1',
            'refreshTokenExpiresIn': 2592000,
          });
        }
        if (options.path == '/v1/driver/context') {
          return _jsonResponse({
            'actorId': 'actor-1',
            'displayName': 'Local Dev Driver',
            'email': 'driver.localdev@example.invalid',
            'effectivePermissionCodes': <String>[],
            'capabilities': <String>[],
            'profiles': [
              {
                'organizationId': 'org-1',
                'organizationName': 'Local Development Driver Org',
                'countryId': 'country-1',
                'countryCode': 'CG',
                'deliveryProfileId': null,
                'deliveryStatus': null,
                'mobilityProfileId': 'profile-1',
                'mobilityOnboardingStatus': 'APPROVED',
                'mobilityOperationalStatus': 'ACTIVE',
                'mobilityAvailabilityStatus': 'OFFLINE',
                'serviceTypes': ['TAXI'],
                'assignedVehicle': null,
              },
            ],
          });
        }
        throw StateError('Unexpected request: ${options.path}');
      },
    );

    // The regression was a genuine, permanent hang - not a slow operation.
    // Bounding it here turns any reintroduction of the deadlock into a fast,
    // clear test failure instead of a CI job that never finishes.
    await container
        .read(authControllerProvider.notifier)
        .login(email: 'driver.localdev@example.invalid', password: 'irrelevant-in-this-test')
        .timeout(const Duration(seconds: 5));

    expect(container.read(authControllerProvider).status, AuthStatus.authenticated);
  });

  test('login state exits the loading spinner and stays unauthenticated when storage persistence fails', () async {
    final storage = _ThrowingWriteStorage();
    final container = _buildRealGraphContainer(
      storage: storage,
      httpHandler: (options) async {
        expect(options.path, '/v1/auth/login');
        return _jsonResponse({
          'tokenType': 'Bearer',
          'accessToken': 'access-1',
          'accessTokenExpiresIn': 900,
          'refreshToken': 'refresh-1',
          'refreshTokenExpiresIn': 2592000,
        });
      },
    );

    // AuthController.login's own internal safety timeout is 10s (see
    // AuthController._storageTimeout) - this outer bound only needs to be
    // comfortably longer than that so the internal one is what actually
    // fires and gets exercised.
    await container
        .read(authControllerProvider.notifier)
        .login(email: 'driver.localdev@example.invalid', password: 'irrelevant-in-this-test')
        .timeout(const Duration(seconds: 15));

    final state = container.read(authControllerProvider);
    expect(state.status, AuthStatus.unauthenticated, reason: 'must never be left on authenticating');
    expect(state.failure, isNotNull);
  }, timeout: const Timeout(Duration(seconds: 20)));
}

/// Simulates a native secure-storage write that never completes - the same
/// observable shape as the original real-device symptom, at the storage
/// boundary this time, to prove `AuthController.login`'s own finite-failure
/// handling (the `.timeout` + catch-all in `login`) holds regardless of
/// which layer misbehaves.
class _ThrowingWriteStorage implements SecureSessionStorage {
  @override
  Future<void> writeAccessToken(String token) => Completer<void>().future; // never completes
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<void> writeRefreshToken(String token) async {}
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> writeAccessTokenExpiresAt(int epochMillis) async {}
  @override
  Future<int?> readAccessTokenExpiresAt() async => null;
  @override
  Future<void> clear() async {}
}
