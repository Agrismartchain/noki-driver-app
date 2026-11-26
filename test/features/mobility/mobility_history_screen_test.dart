import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/mobility/mobility_history_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

/// MobilityHistoryScreen had zero prior coverage, and its title/empty-state
/// text were hardcoded French literals regardless of the app's selected
/// locale (see the night QA report) - this locks in the fix: the screen now
/// reads both from AppLocalizations like every other screen, so it follows
/// the driver's chosen language instead of always showing French.
void main() {
  testWidgets('shows the localized title and completed rides in English', (
    tester,
  ) async {
    final client = FakeDriverApiClient()
      ..mobilityRideHistoryResponse = [
        MobilityRideDetailDto.fromJson(
          sampleMobilityRide(status: 'COMPLETED'),
        ),
      ];

    await pumpWithProviders(
      tester,
      MobilityHistoryScreen(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
      locale: const Locale('en'),
    );

    expect(find.text('Mobility history'), findsOneWidget);
    expect(find.text('Gare Casa-Voyageurs'), findsOneWidget);
  });

  testWidgets(
    'shows the localized empty state (not the French literal) when there are no completed rides',
    (tester) async {
      final client = FakeDriverApiClient()..mobilityRideHistoryResponse = [];

      await pumpWithProviders(
        tester,
        MobilityHistoryScreen(scope: _scope),
        overrides: [driverApiClientProvider.overrideWithValue(client)],
        locale: const Locale('en'),
      );

      expect(find.text('No completed Mobility rides yet'), findsOneWidget);
      expect(find.text('Aucune course Mobility terminee'), findsNothing);
    },
  );
}
