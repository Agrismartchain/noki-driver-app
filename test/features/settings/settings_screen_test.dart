import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/storage/storage_providers.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/core/ui/noki_ui.dart';
import 'package:noki_driver_app/features/settings/settings_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_session_storage.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

Future<List<Object>> _authenticatedOverrides({
  String mobilityAvailabilityStatus = 'OFFLINE',
}) async {
  final client = FakeDriverApiClient()
    ..driverContextResponse = DriverContextResponseDto.fromJson(
      sampleDriverContext(
        mobilityAvailabilityStatus: mobilityAvailabilityStatus,
      ),
    );
  final storage = FakeSecureSessionStorage();
  await storage.writeAccessToken('access-token');
  await storage.writeRefreshToken('refresh-token');
  return [
    driverApiClientProvider.overrideWithValue(client),
    secureSessionStorageProvider.overrideWithValue(storage),
  ];
}

void main() {
  testWidgets(
    'renders real driver context and labels documents and notifications as backend-required',
    (tester) async {
      final overrides = await _authenticatedOverrides();

      await pumpWithProviders(
        tester,
        const SettingsScreen(),
        overrides: overrides.cast(),
      );

      expect(find.text('Amine Tazi'), findsOneWidget);
      expect(find.text('NOKI Casablanca'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.textContaining('Dacia Logan'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.textContaining('Dacia Logan'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(
          'Driver documents and compliance checkpoints require backend support.',
        ),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.text(
          'Driver documents and compliance checkpoints require backend support.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('A dedicated notifications center requires backend support.'),
        findsOneWidget,
      );
      expect(find.textContaining('KYC'), findsNothing);
    },
  );

  testWidgets('Arabic locale keeps the profile surface RTL', (tester) async {
    final overrides = await _authenticatedOverrides();

    await pumpWithProviders(
      tester,
      const SettingsScreen(),
      overrides: overrides.cast(),
      locale: const Locale('ar'),
    );

    expect(find.text('هوية السائق'), findsOneWidget);
    final directionality = Directionality.of(
      tester.element(find.byType(SettingsScreen)),
    );
    expect(directionality, TextDirection.rtl);
  });

  testWidgets('dark theme renders the redesigned profile surface', (
    tester,
  ) async {
    final overrides = await _authenticatedOverrides();

    await pumpWithProviders(
      tester,
      const SettingsScreen(),
      overrides: overrides.cast(),
      theme: buildNokiTheme(NokiColors.dark, Brightness.dark),
    );

    expect(find.text('Operational status'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('compact profile renders without overflow', (tester) async {
    final overrides = await _authenticatedOverrides();
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithProviders(
      tester,
      const SettingsScreen(),
      overrides: overrides.cast(),
    );

    await tester.scrollUntilVisible(
      find.text('Open vehicles'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Open vehicles'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Mandatory NOKI convention (mission mandate §8), kept consistent with the
  // Home availability badge (see availability_card_test.dart): AVAILABLE is
  // green, BUSY is red, OFFLINE is neutral grey.
  for (final entry in {
    'AVAILABLE': (NokiBadgeTone.success, 'Availability: Available'),
    'BUSY': (NokiBadgeTone.danger, 'Availability: Busy'),
    'OFFLINE': (NokiBadgeTone.offline, 'Availability: Offline'),
  }.entries) {
    testWidgets('renders the profile ${entry.key} availability badge with the mandated color tone', (tester) async {
      final overrides = await _authenticatedOverrides(
        mobilityAvailabilityStatus: entry.key,
      );

      await pumpWithProviders(
        tester,
        const SettingsScreen(),
        overrides: overrides.cast(),
      );

      await tester.scrollUntilVisible(
        find.text(entry.value.$2),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      final badge = tester.widget<NokiBadge>(
        find.ancestor(
          of: find.text(entry.value.$2),
          matching: find.byType(NokiBadge),
        ),
      );
      expect(badge.tone, entry.value.$1);
    });
  }
}
