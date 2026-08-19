import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/location/location_repository.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/mobility/mobility_ride_map_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_location_repository.dart';
import '../../fixtures/fake_tile_provider.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  testWidgets('a DRIVER_ASSIGNED ride shows "mark en route" on the map bottom sheet', (tester) async {
    final client = FakeDriverApiClient()..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide());

    await pumpWithProviders(
      tester,
      MobilityRideMapScreen(
      tileProvider: FakeTileProvider(),
      rideId: 'ride-1', scope: _scope),
      overrides: [
        driverApiClientProvider.overrideWithValue(client),
        locationRepositoryProvider.overrideWithValue(FakeLocationRepository()),
      ],
    );

    expect(find.widgetWithText(ElevatedButton, 'Mark en route'), findsOneWidget);
  });

  testWidgets('tapping a transition on the map bottom sheet calls the same transition endpoint', (tester) async {
    final client = FakeDriverApiClient()
      ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide())
      ..transitionMobilityRideResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide(status: 'DRIVER_EN_ROUTE'));

    await pumpWithProviders(
      tester,
      MobilityRideMapScreen(
      tileProvider: FakeTileProvider(),
      rideId: 'ride-1', scope: _scope),
      overrides: [
        driverApiClientProvider.overrideWithValue(client),
        locationRepositoryProvider.overrideWithValue(FakeLocationRepository()),
      ],
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Mark en route'));
    await tester.pumpAndSettle();

    expect(client.lastTransitionMobilityRideBody?.status, TransitionMobilityRideDtoStatus.driverEnRoute);
  });
}
