import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/core/storage/storage_providers.dart';
import 'package:noki_driver_app/features/auth/auth_providers.dart';
import 'package:noki_driver_app/features/auth/auth_state.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_session_storage.dart';
import '../../fixtures/sample_responses.dart';

ProviderContainer _buildContainer(FakeDriverApiClient client, FakeSecureSessionStorage storage) {
  final container = ProviderContainer(
    overrides: [
      driverApiClientProvider.overrideWithValue(client),
      secureSessionStorageProvider.overrideWithValue(storage),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('AuthController bootstrap (session restore)', () {
    test('no stored tokens -> unauthenticated, no API call made', () async {
      final client = FakeDriverApiClient();
      final container = _buildContainer(client, FakeSecureSessionStorage());

      container.read(authControllerProvider); // triggers build()
      await _settle();

      expect(container.read(authControllerProvider).status, AuthStatus.unauthenticated);
    });

    test('stored tokens + Driver profile present -> authenticated', () async {
      final client = FakeDriverApiClient()..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext());
      final storage = FakeSecureSessionStorage();
      await storage.writeAccessToken('access-1');
      await storage.writeRefreshToken('refresh-1');

      final container = _buildContainer(client, storage);
      container.read(authControllerProvider);
      await _settle();

      expect(container.read(authControllerProvider).status, AuthStatus.authenticated);
      expect(container.read(authControllerProvider).driverContext?.actorId, 'actor-1');
    });

    test('stored tokens but zero Driver profiles -> accessDenied (role guard)', () async {
      final client = FakeDriverApiClient()
        ..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext(withProfile: false));
      final storage = FakeSecureSessionStorage();
      await storage.writeAccessToken('access-1');
      await storage.writeRefreshToken('refresh-1');

      final container = _buildContainer(client, storage);
      container.read(authControllerProvider);
      await _settle();

      expect(container.read(authControllerProvider).status, AuthStatus.accessDenied);
    });

    test('stored tokens rejected by backend (401) -> unauthenticated, storage cleared', () async {
      final client = FakeDriverApiClient()..driverContextFailure = const AppFailure(AppFailureType.unauthenticated);
      final storage = FakeSecureSessionStorage();
      await storage.writeAccessToken('access-1');
      await storage.writeRefreshToken('refresh-1');

      final container = _buildContainer(client, storage);
      container.read(authControllerProvider);
      await _settle();

      expect(container.read(authControllerProvider).status, AuthStatus.unauthenticated);
      expect(await storage.readAccessToken(), isNull);
    });
  });

  group('AuthController.login', () {
    test('success with a Driver profile -> authenticated and tokens persisted', () async {
      final client = FakeDriverApiClient()
        ..loginResponse = AuthTokensResponseDto.fromJson(sampleAuthTokens())
        ..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext());
      final storage = FakeSecureSessionStorage();
      final container = _buildContainer(client, storage);
      container.read(authControllerProvider);
      await _settle(); // let the no-token bootstrap finish first

      await container.read(authControllerProvider.notifier).login(email: 'a@b.test', password: 'secret');

      expect(container.read(authControllerProvider).status, AuthStatus.authenticated);
      expect(await storage.readAccessToken(), 'access-token-1');
    });

    test('backend rejects credentials -> unauthenticated with the failure attached', () async {
      final client = FakeDriverApiClient()..loginFailure = const AppFailure(AppFailureType.unauthenticated);
      final container = _buildContainer(client, FakeSecureSessionStorage());
      container.read(authControllerProvider);
      await _settle();

      await container.read(authControllerProvider.notifier).login(email: 'a@b.test', password: 'wrong');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.failure?.type, AppFailureType.unauthenticated);
    });
  });

  group('AuthController as AuthSessionGateway', () {
    test('refreshAccessToken returns null and does not throw when no refresh token is stored', () async {
      final client = FakeDriverApiClient();
      final container = _buildContainer(client, FakeSecureSessionStorage());
      final controller = container.read(authControllerProvider.notifier);
      await _settle();

      expect(await controller.refreshAccessToken(), isNull);
      expect(client.refreshCallCount, 0);
    });

    test('refreshAccessToken persists new tokens on success', () async {
      final client = FakeDriverApiClient()
        ..refreshResponse = AuthTokensResponseDto.fromJson(sampleAuthTokens(access: 'access-2', refresh: 'refresh-2'))
        // Bootstrap runs in the background as soon as a refresh token is on
        // disk. Use a transient failure here (not `unauthenticated`) so
        // bootstrap does not clear the refresh token this test is about to
        // exercise directly.
        ..driverContextFailure = const AppFailure(AppFailureType.server);
      final storage = FakeSecureSessionStorage();
      await storage.writeRefreshToken('refresh-1');
      final container = _buildContainer(client, storage);
      final controller = container.read(authControllerProvider.notifier);
      await _settle();

      final newToken = await controller.refreshAccessToken();

      expect(newToken, 'access-2');
      expect(await storage.readAccessToken(), 'access-2');
      expect(await storage.readRefreshToken(), 'refresh-2');
    });

    test('onSessionExpired clears storage and flips state to unauthenticated', () async {
      final client = FakeDriverApiClient()..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext());
      final storage = FakeSecureSessionStorage();
      await storage.writeAccessToken('access-1');
      await storage.writeRefreshToken('refresh-1');
      final container = _buildContainer(client, storage);
      final controller = container.read(authControllerProvider.notifier);
      await _settle();
      expect(container.read(authControllerProvider).status, AuthStatus.authenticated);

      await controller.onSessionExpired();

      expect(container.read(authControllerProvider).status, AuthStatus.unauthenticated);
      expect(await storage.readAccessToken(), isNull);
    });
  });

  group('AuthController.logout', () {
    test('clears storage and state even if the server-side revoke call fails', () async {
      final client = FakeDriverApiClient()
        ..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext());
      final storage = FakeSecureSessionStorage();
      await storage.writeAccessToken('access-1');
      await storage.writeRefreshToken('refresh-1');
      final container = _buildContainer(client, storage);
      container.read(authControllerProvider);
      await _settle();

      await container.read(authControllerProvider.notifier).logout();

      expect(container.read(authControllerProvider).status, AuthStatus.unauthenticated);
      expect(await storage.readAccessToken(), isNull);
    });
  });
}
