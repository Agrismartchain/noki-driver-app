import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/api/mfa/mfa_models.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/storage/storage_providers.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/features/auth/auth_providers.dart';
import 'package:noki_driver_app/features/auth/auth_state.dart';
import 'package:noki_driver_app/features/auth/mfa_verify_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_session_storage.dart';
import '../../fixtures/sample_responses.dart';

Future<ProviderContainer> _loginToVerifyRequired(
  WidgetTester tester,
  FakeDriverApiClient client, {
  FakeSecureSessionStorage? storage,
}) async {
  final container = ProviderContainer(
    overrides: [
      driverApiClientProvider.overrideWithValue(client),
      secureSessionStorageProvider.overrideWithValue(storage ?? FakeSecureSessionStorage()),
    ],
  );
  addTearDown(container.dispose);
  container.read(authControllerProvider);
  // Lets the no-token bootstrap settle into `unauthenticated` first - racing
  // it against login() below would let the bootstrap overwrite login's own
  // state transition (see auth_controller_test.dart's `_settle` helper).
  await Future<void>.delayed(Duration.zero);
  await container.read(authControllerProvider.notifier).login(email: 'a@b.test', password: 'secret');

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildNokiTheme(NokiColors.light, Brightness.light),
        home: const MfaVerifyScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

FakeDriverApiClient _verifyClient() => FakeDriverApiClient()
  ..loginMfaChallengeResponse = AuthMfaChallengeResponseDto.fromJson(
    sampleMfaChallenge(mfaStatus: 'VERIFY'),
  );

void main() {
  testWidgets('submitting a valid 6-digit code calls verifyMfa with that code', (tester) async {
    final client = _verifyClient()
      ..mfaVerifyResponse = AuthTokensResponseDto.fromJson(sampleAuthTokens())
      ..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext());
    final storage = FakeSecureSessionStorage();

    final container = await _loginToVerifyRequired(tester, client, storage: storage);

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(client.lastMfaVerifyCode, '123456');
    expect(container.read(authControllerProvider).status, AuthStatus.authenticated);
    expect(await storage.readAccessToken(), 'access-token-1');
  });

  testWidgets('switching to a recovery code shows the recovery field and submits recoveryCode', (tester) async {
    final client = _verifyClient()
      ..mfaVerifyResponse = AuthTokensResponseDto.fromJson(sampleAuthTokens())
      ..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext());

    await _loginToVerifyRequired(tester, client);

    await tester.tap(find.text('Use a recovery code instead'));
    await tester.pumpAndSettle();

    expect(find.text('Recovery code'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget); // the 6-digit field is gone, not just hidden

    await tester.enterText(find.byType(TextFormField), 'ABCD-EFGH-JKMN');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(client.lastMfaVerifyRecoveryCode, 'ABCD-EFGH-JKMN');
    expect(client.lastMfaVerifyCode, isNull);
  });

  testWidgets('shows a clean error message for an invalid code and keeps the challenge', (tester) async {
    final client = _verifyClient()
      ..mfaVerifyFailure = const AppFailure(
        AppFailureType.unauthenticated,
        code: 'MFA_CODE_INVALID',
      );

    final container = await _loginToVerifyRequired(tester, client);

    await tester.enterText(find.byType(TextFormField), '000000');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(find.text("That code isn't valid. Try again."), findsOneWidget);
    expect(container.read(authControllerProvider).status, AuthStatus.mfaVerifyRequired);
  });

  testWidgets('an expired challenge resets to unauthenticated with the failure attached', (tester) async {
    final client = _verifyClient()
      ..mfaVerifyFailure = const AppFailure(
        AppFailureType.unauthenticated,
        code: 'MFA_CHALLENGE_INVALID',
      );

    final container = await _loginToVerifyRequired(tester, client);

    await tester.enterText(find.byType(TextFormField), '000000');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(container.read(authControllerProvider).status, AuthStatus.unauthenticated);
    expect(container.read(authControllerProvider).failure?.code, 'MFA_CHALLENGE_INVALID');
  });
}
