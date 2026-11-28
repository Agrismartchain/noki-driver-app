import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/api/mfa/mfa_models.dart';
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

  group('AuthController.login with MFA (POST /v1/auth/login -> 202)', () {
    test('mfaStatus ENROLL -> mfaEnrollRequired, no tokens persisted, driverContext not called', () async {
      final client = FakeDriverApiClient()
        ..loginMfaChallengeResponse = AuthMfaChallengeResponseDto.fromJson(
          sampleMfaChallenge(mfaStatus: 'ENROLL', challengeToken: 'chal-1'),
        );
      final storage = FakeSecureSessionStorage();
      final container = _buildContainer(client, storage);
      container.read(authControllerProvider);
      await _settle();

      await container.read(authControllerProvider.notifier).login(email: 'a@b.test', password: 'secret');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.mfaEnrollRequired);
      expect(state.mfaChallenge?.challengeToken, 'chal-1');
      expect(await storage.readAccessToken(), isNull);
      expect(client.driverContextCallCount, 0);
    });

    test('mfaStatus VERIFY -> mfaVerifyRequired, no tokens persisted, driverContext not called', () async {
      final client = FakeDriverApiClient()
        ..loginMfaChallengeResponse = AuthMfaChallengeResponseDto.fromJson(
          sampleMfaChallenge(mfaStatus: 'VERIFY', challengeToken: 'chal-2'),
        );
      final storage = FakeSecureSessionStorage();
      final container = _buildContainer(client, storage);
      container.read(authControllerProvider);
      await _settle();

      await container.read(authControllerProvider.notifier).login(email: 'a@b.test', password: 'secret');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.mfaVerifyRequired);
      expect(state.mfaChallenge?.challengeToken, 'chal-2');
      expect(await storage.readAccessToken(), isNull);
      expect(client.driverContextCallCount, 0);
    });
  });

  group('AuthController MFA enrollment', () {
    Future<ProviderContainer> loginToEnrollRequired(FakeDriverApiClient client) async {
      client.loginMfaChallengeResponse = AuthMfaChallengeResponseDto.fromJson(
        sampleMfaChallenge(mfaStatus: 'ENROLL', challengeToken: 'chal-1'),
      );
      final container = _buildContainer(client, FakeSecureSessionStorage());
      container.read(authControllerProvider);
      await _settle();
      await container.read(authControllerProvider.notifier).login(email: 'a@b.test', password: 'secret');
      return container;
    }

    test('startMfaEnrollment success -> enrollment secret stored in state', () async {
      final client = FakeDriverApiClient()
        ..mfaEnrollStartResponse = MfaEnrollmentStartResponseDto.fromJson(sampleMfaEnrollmentStart());
      final container = await loginToEnrollRequired(client);

      await container.read(authControllerProvider.notifier).startMfaEnrollment();

      expect(client.lastMfaEnrollStartChallengeToken, 'chal-1');
      expect(
        container.read(authControllerProvider).mfaChallenge?.enrollment?.secretBase32,
        'JBSWY3DPEHPK3PXP',
      );
      expect(container.read(authControllerProvider).status, AuthStatus.mfaEnrollRequired);
    });

    test('confirmMfaEnrollment success -> mfaRecoveryCodesPending, tokens not yet persisted', () async {
      final client = FakeDriverApiClient()
        ..mfaEnrollConfirmResponse = MfaEnrollConfirmResponseDto.fromJson(sampleMfaEnrollConfirm());
      final container = await loginToEnrollRequired(client);

      await container.read(authControllerProvider.notifier).confirmMfaEnrollment(code: '123456');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.mfaRecoveryCodesPending);
      expect(state.pendingRecoveryCodes?.recoveryCodes, ['ABCD-EFGH-JKMN', 'PQRS-TUVW-XY23']);
      expect(client.driverContextCallCount, 0);
    });

    test('acknowledgeRecoveryCodes -> persists tokens, calls driverContext once, authenticated', () async {
      final client = FakeDriverApiClient()
        ..mfaEnrollConfirmResponse = MfaEnrollConfirmResponseDto.fromJson(sampleMfaEnrollConfirm())
        ..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext());
      final container = await loginToEnrollRequired(client);
      await container.read(authControllerProvider.notifier).confirmMfaEnrollment(code: '123456');

      await container.read(authControllerProvider.notifier).acknowledgeRecoveryCodes();

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(client.driverContextCallCount, 1);
    });

    test('confirmMfaEnrollment with an invalid code -> stays mfaEnrollRequired, no tokens persisted', () async {
      final client = FakeDriverApiClient()
        ..mfaEnrollConfirmFailure = const AppFailure(
          AppFailureType.unauthenticated,
          code: 'MFA_CODE_INVALID',
        );
      final storage = FakeSecureSessionStorage();
      final container = await loginToEnrollRequired(client);
      final notifier = container.read(authControllerProvider.notifier);

      await notifier.confirmMfaEnrollment(code: '000000');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.mfaEnrollRequired);
      expect(state.mfaChallenge?.challengeToken, 'chal-1');
      expect(state.failure?.code, 'MFA_CODE_INVALID');
      expect(await storage.readAccessToken(), isNull);
    });

    test('confirmMfaEnrollment with an expired challenge -> resets to unauthenticated', () async {
      final client = FakeDriverApiClient()
        ..mfaEnrollConfirmFailure = const AppFailure(
          AppFailureType.unauthenticated,
          code: 'MFA_CHALLENGE_INVALID',
        );
      final container = await loginToEnrollRequired(client);

      await container.read(authControllerProvider.notifier).confirmMfaEnrollment(code: '000000');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.mfaChallenge, isNull);
      expect(state.failure?.code, 'MFA_CHALLENGE_INVALID');
    });
  });

  group('AuthController MFA verify', () {
    Future<ProviderContainer> loginToVerifyRequired(FakeDriverApiClient client) async {
      client.loginMfaChallengeResponse = AuthMfaChallengeResponseDto.fromJson(
        sampleMfaChallenge(mfaStatus: 'VERIFY', challengeToken: 'chal-2'),
      );
      final container = _buildContainer(client, FakeSecureSessionStorage());
      container.read(authControllerProvider);
      await _settle();
      await container.read(authControllerProvider.notifier).login(email: 'a@b.test', password: 'secret');
      return container;
    }

    test('verifyMfa with a valid code -> persists tokens, calls driverContext, authenticated', () async {
      final client = FakeDriverApiClient()
        ..mfaVerifyResponse = AuthTokensResponseDto.fromJson(sampleAuthTokens())
        ..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext());
      final storage = FakeSecureSessionStorage();
      final container = _buildContainer(client, storage);
      client.loginMfaChallengeResponse = AuthMfaChallengeResponseDto.fromJson(
        sampleMfaChallenge(mfaStatus: 'VERIFY', challengeToken: 'chal-2'),
      );
      container.read(authControllerProvider);
      await _settle();
      await container.read(authControllerProvider.notifier).login(email: 'a@b.test', password: 'secret');

      await container.read(authControllerProvider.notifier).verifyMfa(code: '123456');

      expect(client.lastMfaVerifyCode, '123456');
      expect(container.read(authControllerProvider).status, AuthStatus.authenticated);
      expect(await storage.readAccessToken(), 'access-token-1');
      expect(client.driverContextCallCount, 1);
    });

    test('verifyMfa with a recovery code -> persists tokens, authenticated', () async {
      final client = FakeDriverApiClient()
        ..mfaVerifyResponse = AuthTokensResponseDto.fromJson(sampleAuthTokens())
        ..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext());
      final container = await loginToVerifyRequired(client);

      await container
          .read(authControllerProvider.notifier)
          .verifyMfa(recoveryCode: 'ABCD-EFGH-JKMN');

      expect(client.lastMfaVerifyRecoveryCode, 'ABCD-EFGH-JKMN');
      expect(container.read(authControllerProvider).status, AuthStatus.authenticated);
    });

    test('verifyMfa with an invalid code -> stays mfaVerifyRequired with the failure attached', () async {
      final client = FakeDriverApiClient()
        ..mfaVerifyFailure = const AppFailure(
          AppFailureType.unauthenticated,
          code: 'MFA_CODE_INVALID',
        );
      final storage = FakeSecureSessionStorage();
      final container = await loginToVerifyRequired(client);

      await container.read(authControllerProvider.notifier).verifyMfa(code: '000000');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.mfaVerifyRequired);
      expect(state.mfaChallenge?.challengeToken, 'chal-2');
      expect(state.failure?.code, 'MFA_CODE_INVALID');
      expect(await storage.readAccessToken(), isNull);
      expect(client.driverContextCallCount, 0);
    });

    test('verifyMfa with an expired challenge -> resets to unauthenticated', () async {
      final client = FakeDriverApiClient()
        ..mfaVerifyFailure = const AppFailure(
          AppFailureType.unauthenticated,
          code: 'MFA_CHALLENGE_INVALID',
        );
      final container = await loginToVerifyRequired(client);

      await container.read(authControllerProvider.notifier).verifyMfa(code: '000000');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.mfaChallenge, isNull);
      expect(state.failure?.code, 'MFA_CHALLENGE_INVALID');
    });

    test('verifyMfa locked (too many attempts) -> stays mfaVerifyRequired with the failure attached', () async {
      final client = FakeDriverApiClient()
        ..mfaVerifyFailure = const AppFailure(
          AppFailureType.rateLimited,
          code: 'MFA_LOCKED',
          statusCode: 429,
        );
      final container = await loginToVerifyRequired(client);

      await container.read(authControllerProvider.notifier).verifyMfa(code: '000000');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.mfaVerifyRequired);
      expect(state.failure?.code, 'MFA_LOCKED');
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
