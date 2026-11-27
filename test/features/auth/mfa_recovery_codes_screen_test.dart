import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/api/mfa/mfa_models.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/storage/storage_providers.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/features/auth/auth_providers.dart';
import 'package:noki_driver_app/features/auth/auth_state.dart';
import 'package:noki_driver_app/features/auth/mfa_recovery_codes_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_session_storage.dart';
import '../../fixtures/sample_responses.dart';

/// Drives the real [AuthController] through login -> enroll -> confirm,
/// reaching `AuthStatus.mfaRecoveryCodesPending` exactly as production does,
/// before mounting [MfaRecoveryCodesScreen].
Future<ProviderContainer> _toRecoveryCodesPending(
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
  container.read(authControllerProvider);
  // Lets the no-token bootstrap settle into `unauthenticated` first - racing
  // it against login() below would let the bootstrap overwrite login's own
  // state transition (see auth_controller_test.dart's `_settle` helper).
  await Future<void>.delayed(Duration.zero);
  final notifier = container.read(authControllerProvider.notifier);
  await notifier.login(email: 'a@b.test', password: 'secret');
  await notifier.confirmMfaEnrollment(code: '123456');

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildNokiTheme(NokiColors.light, Brightness.light),
        home: const MfaRecoveryCodesScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

FakeDriverApiClient _enrollConfirmClient() => FakeDriverApiClient()
  ..loginMfaChallengeResponse = AuthMfaChallengeResponseDto.fromJson(
    sampleMfaChallenge(mfaStatus: 'ENROLL'),
  )
  ..mfaEnrollConfirmResponse = MfaEnrollConfirmResponseDto.fromJson(sampleMfaEnrollConfirm());

void main() {
  testWidgets('shows every recovery code from the pending session', (tester) async {
    await _toRecoveryCodesPending(tester, _enrollConfirmClient());

    expect(find.text('ABCD-EFGH-JKMN'), findsOneWidget);
    expect(find.text('PQRS-TUVW-XY23'), findsOneWidget);
  });

  testWidgets(
    'acknowledging persists tokens, calls driverContext once, and reaches authenticated',
    (tester) async {
      final client = _enrollConfirmClient()
        ..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext());
      final storage = FakeSecureSessionStorage();
      final container = ProviderContainer(
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          secureSessionStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);
      container.read(authControllerProvider);
      await Future<void>.delayed(Duration.zero);
      final notifier = container.read(authControllerProvider.notifier);
      await notifier.login(email: 'a@b.test', password: 'secret');
      await notifier.confirmMfaEnrollment(code: '123456');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: buildNokiTheme(NokiColors.light, Brightness.light),
            home: const MfaRecoveryCodesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("I've saved these codes"));
      await tester.pumpAndSettle();

      expect(container.read(authControllerProvider).status, AuthStatus.authenticated);
      expect(client.driverContextCallCount, 1);
      expect(await storage.readAccessToken(), 'access-token-1');
    },
  );
}
