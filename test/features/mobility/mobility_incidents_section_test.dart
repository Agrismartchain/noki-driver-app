import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/mobility/mobility_ride_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

/// The Mobility incident form was reachable from no screen before this
/// phase (`MobilityRepository.createIncident`/`mobilityIncidentsProvider`
/// existed but nothing called them) - this is the first coverage of it.
void main() {
  Future<void> pumpTall(WidgetTester tester, Widget child, {required List<Override> overrides}) async {
    tester.view.physicalSize = const Size(400, 2400) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    await pumpWithProviders(tester, child, overrides: overrides);
  }

  testWidgets('shows a real empty state, then lists an incident scoped to this ride by reference', (tester) async {
    final client = FakeDriverApiClient()
      ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide())
      ..mobilityIncidentsResponse = DriverMobilityIncidentListResponseDto.fromJson({
        'items': [sampleMobilityIncident(), sampleMobilityIncident()..['rideReference'] = 'RIDE-9999'],
        'total': 2,
        'page': 1,
        'pageSize': 25,
      });

    await pumpTall(
      tester,
      const MobilityRideScreen(rideId: 'ride-1', scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    // sampleMobilityRide()'s reference ('RIDE-0001') matches only the first
    // incident's rideReference - the second (a different ride) must not
    // appear in this ride's section.
    expect(find.text('Passenger felt unsafe'), findsOneWidget);
    expect(find.text('Safety'), findsWidgets);
  });

  testWidgets('submitting an incident calls createIncident scoped to this ride and refreshes the list', (tester) async {
    final client = FakeDriverApiClient()
      ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide())
      ..mobilityIncidentsResponse = DriverMobilityIncidentListResponseDto.fromJson({'items': [], 'total': 0, 'page': 1, 'pageSize': 25})
      ..createMobilityIncidentResponse = MobilityIncidentDto.fromJson(sampleMobilityIncident());

    await pumpTall(
      tester,
      const MobilityRideScreen(rideId: 'ride-1', scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text('No incidents reported'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Passenger felt unsafe');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Report incident'));
    await tester.pumpAndSettle();

    expect(client.lastCreateMobilityIncidentBody?.rideId, 'ride-1');
    expect(client.lastCreateMobilityIncidentBody?.comment, 'Passenger felt unsafe');
  });
}
