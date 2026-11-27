import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/mfa/mfa_models.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/storage/storage_providers.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/features/auth/auth_providers.dart';
import 'package:noki_driver_app/features/auth/mfa_enroll_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_session_storage.dart';
import '../../fixtures/sample_responses.dart';

/// Drives the real [AuthController] into `AuthStatus.mfaEnrollRequired`
/// before mounting [MfaEnrollScreen] - the screen itself never fabricates
/// that state, so these tests exercise the real login -> enroll hand-off.
Future<ProviderContainer> _loginToEnrollRequired(
  WidgetTester tester,
  FakeDriverApiClient client,
) async {
  final container = ProviderContainer(
    overrides: [
      driverApiClientProvider.overrideWithValue(client),
      secureSessionStorageProvider.overrideWithValue(FakeSecureSessionStorage()),
    ],
  );
  addTearDown(container.dispose);
  container.read(authControllerProvider); // triggers build() / bootstrap
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
        home: const MfaEnrollScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

FakeDriverApiClient _enrollClient() => FakeDriverApiClient()
  ..loginMfaChallengeResponse = AuthMfaChallengeResponseDto.fromJson(
    sampleMfaChallenge(mfaStatus: 'ENROLL'),
  )
  ..mfaEnrollStartResponse = MfaEnrollmentStartResponseDto.fromJson(sampleMfaEnrollmentStart());

void main() {
  testWidgets('fetches the enrollment secret automatically and shows it', (tester) async {
    final client = _enrollClient();

    await _loginToEnrollRequired(tester, client);

    expect(find.text('JBSWY3DPEHPK3PXP'), findsOneWidget);
    expect(client.mfaEnrollStartCallCount, 1);
  });

  testWidgets('submitting a valid 6-digit code calls confirmMfaEnrollment', (tester) async {
    final client = _enrollClient()
      ..mfaEnrollConfirmResponse = MfaEnrollConfirmResponseDto.fromJson(sampleMfaEnrollConfirm());

    await _loginToEnrollRequired(tester, client);

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(client.lastMfaEnrollConfirmCode, '123456');
  });

  testWidgets('rejects a non-6-digit code without calling the backend', (tester) async {
    final client = _enrollClient();

    await _loginToEnrollRequired(tester, client);

    await tester.enterText(find.byType(TextFormField), '123');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Enter the 6 digits shown in your app'), findsOneWidget);
    expect(client.mfaEnrollConfirmCallCount, 0);
  });

  testWidgets('shows a clean error message for an invalid code and keeps the secret visible', (tester) async {
    final client = _enrollClient()
      ..mfaEnrollConfirmFailure = const AppFailure(
        AppFailureType.unauthenticated,
        code: 'MFA_CODE_INVALID',
      );

    await _loginToEnrollRequired(tester, client);

    await tester.enterText(find.byType(TextFormField), '000000');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text("That code isn't valid. Try again."), findsOneWidget);
    expect(find.text('JBSWY3DPEHPK3PXP'), findsOneWidget);
  });
}
