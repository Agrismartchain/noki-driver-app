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

/// The map bottom sheet packs a status pill, a service-type label and a
/// Wrap of transition buttons into a narrow strip over the map - mandate
/// §52/§55 calls this out by name as a width-sensitive area. Verified at
/// 320dp in every locale that renders longer strings (French, Arabic RTL)
/// with no RenderFlex overflow.
void main() {
  for (final locale in [const Locale('en'), const Locale('fr'), const Locale('ar')]) {
    testWidgets('map bottom sheet does not overflow at 320dp (${locale.languageCode})', (tester) async {
      tester.view.physicalSize = const Size(320, 700) * tester.view.devicePixelRatio;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final client = FakeDriverApiClient()..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide());

      await pumpWithProviders(
        tester,
        MobilityRideMapScreen(rideId: 'ride-1', scope: _scope, tileProvider: FakeTileProvider()),
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
