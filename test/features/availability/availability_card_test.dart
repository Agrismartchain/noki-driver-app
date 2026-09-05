import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/core/ui/noki_ui.dart';
import 'package:noki_driver_app/features/availability/availability_card.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  testWidgets('shows the current availability status as the selected chip', (tester) async {
    final client = FakeDriverApiClient()
      ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(sampleAvailability(mobilityStatus: 'AVAILABLE'));

    await pumpWithProviders(
      tester,
      AvailabilityCard(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    final chip = tester.widget<ChoiceChip>(
      find.ancestor(of: find.text('Available'), matching: find.byType(ChoiceChip)),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('tapping a status sends the exact backend enum value and refreshes on success', (tester) async {
    final client = FakeDriverApiClient()
      ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(sampleAvailability(mobilityStatus: 'OFFLINE'));

    await pumpWithProviders(
      tester,
      AvailabilityCard(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    await tester.tap(find.text('Available'));
    await tester.pumpAndSettle();

    expect(client.lastAvailabilityUpdate?.availabilityStatus, UpdateDriverAvailabilityDtoAvailabilityStatus.available);
    expect(client.lastAvailabilityUpdate?.organizationId, 'org-1');
    expect(client.lastAvailabilityUpdate?.countryCode, 'MA');
  });

  testWidgets('shows an error message if the update call fails, without pretending it succeeded', (tester) async {
    final client = FakeDriverApiClient()
      ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(sampleAvailability(mobilityStatus: 'OFFLINE'));

    await pumpWithProviders(
      tester,
      AvailabilityCard(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    client.availabilityFailure = const AppFailure(AppFailureType.server);
    await tester.tap(find.text('Available'));
    await tester.pumpAndSettle();

    expect(find.text('Could not update your availability'), findsOneWidget);
  });

  // Mandatory NOKI convention (mission mandate §8): AVAILABLE is green,
  // BUSY is red, OFFLINE is neutral grey - never the brand/warning tones.
  for (final entry in {
    'AVAILABLE': NokiBadgeTone.success,
    'BUSY': NokiBadgeTone.danger,
    'OFFLINE': NokiBadgeTone.offline,
  }.entries) {
    testWidgets('renders the ${entry.key} status badge with the mandated color tone', (tester) async {
      final client = FakeDriverApiClient()
        ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(sampleAvailability(mobilityStatus: entry.key));

      await pumpWithProviders(
        tester,
        AvailabilityCard(scope: _scope),
        overrides: [driverApiClientProvider.overrideWithValue(client)],
      );

      final label = switch (entry.key) {
        'AVAILABLE' => 'Available',
        'BUSY' => 'Busy',
        _ => 'Offline',
      };
      final badge = tester.widget<NokiBadge>(
        find.ancestor(of: find.text(label), matching: find.byType(NokiBadge)),
      );
      expect(badge.tone, entry.value);
    });
  }
}
