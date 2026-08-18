import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/core/storage/storage_providers.dart';
import 'package:noki_driver_app/features/auth/login_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_session_storage.dart';
import '../../fixtures/test_harness.dart';

void main() {
  testWidgets('shows validation errors when submitting an empty form', (tester) async {
    final client = FakeDriverApiClient();
    await pumpWithProviders(
      tester,
      const LoginScreen(),
      overrides: [
        driverApiClientProvider.overrideWithValue(client),
        secureSessionStorageProvider.overrideWithValue(FakeSecureSessionStorage()),
      ],
    );

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email address'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(client.loginCallCount, 0);
  });

  testWidgets('rejects a malformed email address', (tester) async {
    await pumpWithProviders(
      tester,
      const LoginScreen(),
      overrides: [
        driverApiClientProvider.overrideWithValue(FakeDriverApiClient()),
        secureSessionStorageProvider.overrideWithValue(FakeSecureSessionStorage()),
      ],
    );

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.enterText(find.byType(TextFormField).last, 'secret');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('shows a loading indicator while the login call is in flight', (tester) async {
    final client = FakeDriverApiClient()..loginDelay = const Duration(milliseconds: 200);
    client.loginFailure = const AppFailure(AppFailureType.unauthenticated);

    await pumpWithProviders(
      tester,
      const LoginScreen(),
      overrides: [
        driverApiClientProvider.overrideWithValue(client),
        secureSessionStorageProvider.overrideWithValue(FakeSecureSessionStorage()),
      ],
    );

    await tester.enterText(find.byType(TextFormField).first, 'driver@example.test');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text('Sign in'));
    await tester.pump(); // one frame: authenticating state should be visible

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('shows a clean error message when the backend rejects credentials', (tester) async {
    final client = FakeDriverApiClient()..loginFailure = const AppFailure(AppFailureType.unauthenticated);

    await pumpWithProviders(
      tester,
      const LoginScreen(),
      overrides: [
        driverApiClientProvider.overrideWithValue(client),
        secureSessionStorageProvider.overrideWithValue(FakeSecureSessionStorage()),
      ],
    );

    await tester.enterText(find.byType(TextFormField).first, 'driver@example.test');
    await tester.enterText(find.byType(TextFormField).last, 'wrong-password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Your session has expired. Sign in again.'), findsOneWidget);
  });

  testWidgets('toggling the password visibility icon reveals the password field', (tester) async {
    await pumpWithProviders(
      tester,
      const LoginScreen(),
      overrides: [
        driverApiClientProvider.overrideWithValue(FakeDriverApiClient()),
        secureSessionStorageProvider.overrideWithValue(FakeSecureSessionStorage()),
      ],
    );

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
  });
}
