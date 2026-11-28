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
import 'package:noki_driver_app/features/auth/auth_state.dart';
import 'package:noki_driver_app/features/auth/mfa_enroll_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_session_storage.dart';
import '../../fixtures/sample_responses.dart';

/// Pumps frames until the no-token bootstrap genuinely settles into
/// `unauthenticated` (polling the real state rather than guessing at a
/// microtask count) before returning - calling `login()` while bootstrap is
/// still in flight races the two state transitions against each other, and
/// whichever finishes last silently overwrites the other. `auth_controller_test.dart`
/// avoids this with a plain `Future.delayed(Duration.zero)` (`_settle`),
/// which works there because bare `test()` blocks run on the real event
/// loop; inside `testWidgets`' fake-async clock, a bare `Future.delayed`
/// never fires without an explicit `tester.pump()` to advance it, so this
/// polls via pumps instead. Requires a widget already mounted (pumps a
/// trivial placeholder first).
Future<void> _settleBootstrap(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(const SizedBox.shrink());
  while (container.read(authControllerProvider).status == AuthStatus.bootstrapping) {
    await tester.pump();
  }
}

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
  await _settleBootstrap(tester, container);
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
    // Not pumpAndSettle(): a successful confirm moves AuthStatus to
    // mfaRecoveryCodesPending, which clears mfaChallenge entirely. Routed
    // through the real app, go_router navigates away from this screen the
    // moment that happens; pumped in isolation here (no router), the same
    // screen stays mounted with no enrollment secret left to show and would
    // render its indeterminate loading spinner forever, which pumpAndSettle
    // can never settle past. A few bounded pumps are enough to observe the
    // call this test actually cares about.
    await tester.pump();
    await tester.pump();

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
