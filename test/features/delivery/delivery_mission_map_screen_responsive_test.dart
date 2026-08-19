import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/location/location_repository.dart';
import 'package:noki_driver_app/features/delivery/delivery_mission_map_screen.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_location_repository.dart';
import '../../fixtures/fake_tile_provider.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

/// See the identical rationale in
/// mobility_ride_map_screen_responsive_test.dart - the bottom sheet's
/// status pill + truncated next-action hint + "Details" button is the
/// width-sensitive strip mandate §52/§55 calls out by name.
void main() {
  for (final locale in [const Locale('en'), const Locale('fr'), const Locale('ar')]) {
    testWidgets('map bottom sheet does not overflow at 320dp (${locale.languageCode})', (tester) async {
      tester.view.physicalSize = const Size(320, 700) * tester.view.devicePixelRatio;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final client = FakeDriverApiClient()
        ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(sampleMission())
        ..deliveryMissionIncidentsResponse = [];
      final feedItem = DriverWorkFeedItemDto.fromJson(sampleWorkFeedDeliveryItem());

      await pumpWithProviders(
        tester,
        DeliveryMissionMapScreen(missionId: 'shipment-1', scope: _scope, feedItem: feedItem, tileProvider: FakeTileProvider()),
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(FakeLocationRepository()),
        ],
        locale: locale,
      );

      expect(tester.takeException(), isNull);
    });
  }
}
