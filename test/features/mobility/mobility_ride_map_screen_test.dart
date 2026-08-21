import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
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
  testWidgets(
    'a DRIVER_ASSIGNED ride shows "mark en route" on the map bottom sheet',
    (tester) async {
      final client = FakeDriverApiClient()
        ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(
          sampleMobilityRide(),
        );

      await pumpWithProviders(
        tester,
        MobilityRideMapScreen(
          tileProvider: FakeTileProvider(),
          rideId: 'ride-1',
          scope: _scope,
        ),
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(
            FakeLocationRepository(),
          ),
        ],
      );

      expect(
        find.widgetWithText(ElevatedButton, 'Mark en route'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'tapping a transition on the map bottom sheet calls the same transition endpoint',
    (tester) async {
      final client = FakeDriverApiClient()
        ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(
          sampleMobilityRide(),
        )
        ..transitionMobilityRideResponse = MobilityRideDetailDto.fromJson(
          sampleMobilityRide(status: 'DRIVER_EN_ROUTE'),
        );

      await pumpWithProviders(
        tester,
        MobilityRideMapScreen(
          tileProvider: FakeTileProvider(),
          rideId: 'ride-1',
          scope: _scope,
        ),
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(
            FakeLocationRepository(),
          ),
        ],
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Mark en route'));
      await tester.pumpAndSettle();

      expect(
        client.lastTransitionMobilityRideBody?.status,
        TransitionMobilityRideDtoStatus.driverEnRoute,
      );
    },
  );

  testWidgets(
    'a driver-assigned ride (pre-pickup) routes to the pickup point and draws the polyline',
    (tester) async {
      final client = FakeDriverApiClient()
        ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(
          sampleMobilityRide(),
        )
        ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
          sampleComputeRouteResponse(),
        );

      await pumpWithProviders(
        tester,
        MobilityRideMapScreen(
          tileProvider: FakeTileProvider(),
          rideId: 'ride-1',
          scope: _scope,
        ),
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(
            FakeLocationRepository(),
          ),
        ],
      );

      final ride = sampleMobilityRide();
      expect(
        client.lastComputeRouteRequest?.destination.latitude,
        ride['pickupLatitude'],
      );
      expect(
        client.lastComputeRouteRequest?.serviceType,
        ComputeDriverRouteRequestDtoServiceType.taxi,
      );
      expect(find.byType(PolylineLayer), findsOneWidget);

      // The canonical ride payload is untouched, and no offer is re-fetched -
      // the screen is fed straight from `mobilityRideByIdResponse`.
      expect(client.mobilityOffersResponse, isNull);
    },
  );

  testWidgets(
    'an in-progress ride (post-pickup) routes to the drop-off point',
    (tester) async {
      final client = FakeDriverApiClient()
        ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(
          sampleMobilityRide(status: 'IN_PROGRESS'),
        )
        ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
          sampleComputeRouteResponse(),
        );

      await pumpWithProviders(
        tester,
        MobilityRideMapScreen(
          tileProvider: FakeTileProvider(),
          rideId: 'ride-1',
          scope: _scope,
        ),
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(
            FakeLocationRepository(),
          ),
        ],
      );

      final ride = sampleMobilityRide();
      expect(
        client.lastComputeRouteRequest?.destination.latitude,
        ride['dropoffLatitude'],
      );
    },
  );

  testWidgets('a taxi-moto ride requests the taxiMoto routing profile', (
    tester,
  ) async {
    final rideJson = sampleMobilityRide()..['serviceType'] = 'TAXI_MOTO';
    final client = FakeDriverApiClient()
      ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(rideJson)
      ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
        sampleComputeRouteResponse(),
      );

    await pumpWithProviders(
      tester,
      MobilityRideMapScreen(
        tileProvider: FakeTileProvider(),
        rideId: 'ride-1',
        scope: _scope,
      ),
      overrides: [
        driverApiClientProvider.overrideWithValue(client),
        locationRepositoryProvider.overrideWithValue(FakeLocationRepository()),
      ],
    );

    expect(
      client.lastComputeRouteRequest?.serviceType,
      ComputeDriverRouteRequestDtoServiceType.taxiMoto,
    );
  });

  testWidgets(
    'a degraded route shows the unavailable message but the fare and transitions remain usable',
    (tester) async {
      final client = FakeDriverApiClient()
        ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(
          sampleMobilityRide(),
        )
        ..computeRouteFailure = const AppFailure(AppFailureType.timeout);

      await pumpWithProviders(
        tester,
        MobilityRideMapScreen(
          tileProvider: FakeTileProvider(),
          rideId: 'ride-1',
          scope: _scope,
        ),
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(
            FakeLocationRepository(),
          ),
        ],
      );

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MobilityRideMapScreen)),
      );
      expect(find.text(l10n.navigationRouteUnavailable), findsOneWidget);
      expect(find.byType(PolylineLayer), findsNothing);
      expect(
        find.text(l10n.financeEstimatedFareLabel.toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(ElevatedButton, 'Mark en route'),
        findsOneWidget,
      );
    },
  );

  testWidgets('a completed ride offers no navigation route at all', (
    tester,
  ) async {
    final client = FakeDriverApiClient()
      ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(
        sampleMobilityRide(status: 'COMPLETED'),
      );

    await pumpWithProviders(
      tester,
      MobilityRideMapScreen(
        tileProvider: FakeTileProvider(),
        rideId: 'ride-1',
        scope: _scope,
      ),
      overrides: [
        driverApiClientProvider.overrideWithValue(client),
        locationRepositoryProvider.overrideWithValue(FakeLocationRepository()),
      ],
    );

    expect(client.computeRouteCallCount, 0);
  });
}
