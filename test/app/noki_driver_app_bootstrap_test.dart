import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/app/noki_driver_app.dart';
import 'package:noki_driver_app/core/storage/storage_providers.dart';
import 'package:noki_driver_app/features/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fixtures/fake_session_storage.dart';

/// Regression coverage for DRIVER-APP-01R3: a genuine, literal provider
/// cycle -
///
///   authControllerProvider.build()
///     -> ref.watch(driverApiClientProvider)
///       -> driverApiDioProvider.build()
///         -> ref.watch(authSessionGatewayProvider)
///           -> ref.watch(authControllerProvider.notifier)
///
/// - threw a real `CircularDependencyError` the first time `authControllerProvider`
/// was read from the real, non-overridden provider graph (previously masked
/// by RD-1 preventing the app from ever rendering that far on a real device;
/// never caught by other tests because they override `driverApiClientProvider`,
/// which breaks the cycle before it can form).
///
/// This test pumps the real `NokiDriverApp` widget tree against the real,
/// non-overridden `appRouterProvider` / `authControllerProvider` /
/// `driverApiClientProvider` / `authSessionGatewayProvider` graph - the actual
/// cycle under test is never mocked away. Only `secureSessionStorageProvider`
/// is overridden, which is the legitimate platform boundary (swapping the
/// real Android Keystore/iOS Keychain channel for an in-memory fake, exactly
/// as `FlutterSecureSessionStorage`'s own class doc prescribes for tests) -
/// with empty storage, session bootstrap resolves to `unauthenticated`
/// without ever making a real network call, so this stays fast and
/// deterministic while still exercising the real DI cycle.
void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('real provider graph pumps to Login with no CircularDependencyError', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [secureSessionStorageProvider.overrideWithValue(FakeSecureSessionStorage())],
        child: const NokiDriverApp(),
      ),
    );

    // The first frame alone is where DRIVER-APP-01R3's cycle threw -
    // synchronously, during the very first widget-mount pass, before any
    // pump() call returns control here.
    expect(tester.takeException(), isNull, reason: 'first frame must not throw CircularDependencyError');

    // Let the async bootstrap (fake storage read -> unauthenticated) and the
    // resulting go_router redirect settle.
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'bootstrap/redirect settling must not throw');
    expect(find.byType(LoginScreen), findsOneWidget, reason: 'unauthenticated with empty storage must land on Login');
    expect(find.byType(TextFormField), findsNWidgets(2), reason: 'email + password fields must be present');
  });
}
