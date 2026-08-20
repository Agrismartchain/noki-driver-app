import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/location/location_permission_state.dart';
import 'package:noki_driver_app/core/location/location_repository.dart';
import 'package:noki_driver_app/features/delivery/delivery_mission_map_screen.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_location_repository.dart';
import '../../fixtures/fake_tile_provider.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  testWidgets('location denied state renders the Master OS permission prompt', (
    tester,
  ) async {
    final client = FakeDriverApiClient()
      ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(
        sampleMission(),
      )
      ..deliveryMissionIncidentsResponse = [];

    await pumpWithProviders(
      tester,
      DeliveryMissionMapScreen(
        missionId: 'shipment-1',
        scope: _scope,
        tileProvider: FakeTileProvider(),
      ),
      overrides: [
        driverApiClientProvider.overrideWithValue(client),
        locationRepositoryProvider.overrideWithValue(
          FakeLocationRepository(state: LocationPermissionState.deniedForever),
        ),
      ],
    );

    expect(
      find.text(
        'Location access was permanently denied. Enable it in Settings to use the map.',
      ),
      findsOneWidget,
    );
    expect(find.text('Open settings'), findsOneWidget);
  });

  testWidgets('GPS-disabled state renders without faking driver coordinates', (
    tester,
  ) async {
    final client = FakeDriverApiClient()
      ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(
        sampleMission(),
      )
      ..deliveryMissionIncidentsResponse = [];

    await pumpWithProviders(
      tester,
      DeliveryMissionMapScreen(
        missionId: 'shipment-1',
        scope: _scope,
        tileProvider: FakeTileProvider(),
      ),
      overrides: [
        driverApiClientProvider.overrideWithValue(client),
        locationRepositoryProvider.overrideWithValue(
          FakeLocationRepository(
            state: LocationPermissionState.serviceDisabled,
          ),
        ),
      ],
    );

    expect(
      find.text(
        'Location services are turned off on this device. Enable them to use the map.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('noki-map-marker-driver')), findsNothing);
  });
}
