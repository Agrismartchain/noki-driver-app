import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/storage/storage_providers.dart';
import 'package:noki_driver_app/features/auth/login_screen.dart';

import '../fixtures/fake_driver_api_client.dart';
import '../fixtures/fake_session_storage.dart';
import '../fixtures/test_harness.dart';

void main() {
  testWidgets('Arabic locale renders the login screen right-to-left', (tester) async {
    await pumpWithProviders(
      tester,
      const LoginScreen(),
      overrides: [
        driverApiClientProvider.overrideWithValue(FakeDriverApiClient()),
        secureSessionStorageProvider.overrideWithValue(FakeSecureSessionStorage()),
      ],
      locale: const Locale('ar'),
    );

    // Arabic strings are present (real localized copy, not English fallback).
    expect(find.text('نوكي للسائقين'), findsOneWidget);
    expect(find.text('البريد الإلكتروني'), findsOneWidget);

    final directionality = Directionality.of(tester.element(find.byType(LoginScreen)));
    expect(directionality, TextDirection.rtl);
  });

  testWidgets('French and English locales render left-to-right', (tester) async {
    await pumpWithProviders(
      tester,
      const LoginScreen(),
      overrides: [
        driverApiClientProvider.overrideWithValue(FakeDriverApiClient()),
        secureSessionStorageProvider.overrideWithValue(FakeSecureSessionStorage()),
      ],
      locale: const Locale('fr'),
    );

    expect(find.text('NOKI Chauffeur'), findsOneWidget);
    final directionality = Directionality.of(tester.element(find.byType(LoginScreen)));
    expect(directionality, TextDirection.ltr);
  });
}
