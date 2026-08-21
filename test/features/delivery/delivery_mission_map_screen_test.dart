import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
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
  testWidgets(
    'an out-for-delivery mission shows its status and the OTP next-action hint on the map bottom sheet',
    (tester) async {
      final client = FakeDriverApiClient()
        ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(
          sampleMission(),
        )
        ..deliveryMissionIncidentsResponse = [];
      final feedItem = DriverWorkFeedItemDto.fromJson(
        sampleWorkFeedDeliveryItem(),
      );

      await pumpWithProviders(
        tester,
        DeliveryMissionMapScreen(
          tileProvider: FakeTileProvider(),
          missionId: 'shipment-1',
          scope: _scope,
          feedItem: feedItem,
        ),
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(
            FakeLocationRepository(),
          ),
        ],
      );

      expect(find.text('Out for delivery'), findsWidgets);
      expect(
        find.text('Request the handoff code to complete this delivery'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'an assigned (not yet out-for-delivery) mission does not offer the OTP hint',
    (tester) async {
      final client = FakeDriverApiClient()
        ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(
          sampleMission(status: 'ASSIGNED'),
        )
        ..deliveryMissionIncidentsResponse = [];

      await pumpWithProviders(
        tester,
        DeliveryMissionMapScreen(
          tileProvider: FakeTileProvider(),
          missionId: 'shipment-1',
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
        find.text('Request the handoff code to complete this delivery'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'an out-for-delivery mission with a real route draws the polyline and an ETA/distance readout',
    (tester) async {
      final client = FakeDriverApiClient()
        ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(
          sampleMission(),
        )
        ..deliveryMissionIncidentsResponse = []
        ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
          sampleComputeRouteResponse(),
        );
      final feedItem = DriverWorkFeedItemDto.fromJson(
        sampleWorkFeedDeliveryItem(),
      );

      await pumpWithProviders(
        tester,
        DeliveryMissionMapScreen(
          tileProvider: FakeTileProvider(),
          missionId: 'shipment-1',
          scope: _scope,
          feedItem: feedItem,
        ),
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(
            FakeLocationRepository(),
          ),
        ],
      );

      // Package is already with the driver (OUT_FOR_DELIVERY) - routes to
      // drop-off, not pickup.
      expect(
        client.lastComputeRouteRequest?.destination.latitude,
        sampleWorkFeedDeliveryItem()['dropoff']['latitude'],
      );
      expect(
        client.lastComputeRouteRequest?.serviceType,
        ComputeDriverRouteRequestDtoServiceType.delivery,
      );
      expect(find.byType(PolylineLayer), findsOneWidget);
      expect(find.textContaining('24.1 km'), findsOneWidget);

      // COD callout stays visible and distinct from the new navigation chrome.
      final l10n = AppLocalizations.of(
        tester.element(find.byType(DeliveryMissionMapScreen)),
      );
      expect(
        find.text(l10n.financeAmountToCollectLabel.toUpperCase()),
        findsOneWidget,
      );
    },
  );

  testWidgets('an assigned mission routes to pickup, not drop-off', (
    tester,
  ) async {
    final client = FakeDriverApiClient()
      ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(
        sampleMission(status: 'ASSIGNED'),
      )
      ..deliveryMissionIncidentsResponse = []
      ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
        sampleComputeRouteResponse(),
      );
    final feedItem = DriverWorkFeedItemDto.fromJson(
      sampleWorkFeedDeliveryItem(),
    );

    await pumpWithProviders(
      tester,
      DeliveryMissionMapScreen(
        tileProvider: FakeTileProvider(),
        missionId: 'shipment-1',
        scope: _scope,
        feedItem: feedItem,
      ),
      overrides: [
        driverApiClientProvider.overrideWithValue(client),
        locationRepositoryProvider.overrideWithValue(FakeLocationRepository()),
      ],
    );

    expect(
      client.lastComputeRouteRequest?.destination.latitude,
      sampleWorkFeedDeliveryItem()['pickup']['latitude'],
    );
  });

  testWidgets(
    'a degraded route shows the unavailable message but keeps the mission fully actionable',
    (tester) async {
      final client = FakeDriverApiClient()
        ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(
          sampleMission(),
        )
        ..deliveryMissionIncidentsResponse = []
        ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
          sampleComputeRouteResponse(
            providerStatus: 'PROVIDER_UNAVAILABLE',
            withGeometry: false,
          ),
        );
      final feedItem = DriverWorkFeedItemDto.fromJson(
        sampleWorkFeedDeliveryItem(),
      );

      await pumpWithProviders(
        tester,
        DeliveryMissionMapScreen(
          tileProvider: FakeTileProvider(),
          missionId: 'shipment-1',
          scope: _scope,
          feedItem: feedItem,
        ),
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(
            FakeLocationRepository(),
          ),
        ],
      );

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DeliveryMissionMapScreen)),
      );
      expect(find.text(l10n.navigationRouteUnavailable), findsOneWidget);
      expect(find.byType(PolylineLayer), findsNothing);

      // Mission remains fully operable: status, OTP next-action hint, "Details".
      expect(
        find.text('Request the handoff code to complete this delivery'),
        findsOneWidget,
      );
      expect(find.text(l10n.missionMapBackToDetails), findsOneWidget);
      expect(
        find.text(l10n.financeAmountToCollectLabel.toUpperCase()),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'a driver whose assigned vehicle for this scope is a motorcycle routes the DELIVERY request with vehicleMode motorcycle',
    (tester) async {
      final client = FakeDriverApiClient()
        ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(
          sampleMission(),
        )
        ..deliveryMissionIncidentsResponse = []
        ..driverContextResponse = DriverContextResponseDto.fromJson(
          sampleDriverContext(vehicleType: 'MOTORCYCLE'),
        )
        ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
          sampleComputeRouteResponse(),
        );
      final feedItem = DriverWorkFeedItemDto.fromJson(
        sampleWorkFeedDeliveryItem(),
      );

      await pumpWithProviders(
        tester,
        DeliveryMissionMapScreen(
          tileProvider: FakeTileProvider(),
          missionId: 'shipment-1',
          scope: _scope,
          feedItem: feedItem,
        ),
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(
            FakeLocationRepository(),
          ),
        ],
      );

      expect(
        client.lastComputeRouteRequest?.vehicleMode,
        ComputeDriverRouteRequestDtoVehicleMode.motorcycle,
      );
    },
  );

  testWidgets(
    'a mission with no assigned vehicle for this scope routes the DELIVERY request with vehicleMode null',
    (tester) async {
      final client = FakeDriverApiClient()
        ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(
          sampleMission(),
        )
        ..deliveryMissionIncidentsResponse = []
        ..driverContextResponse = DriverContextResponseDto.fromJson(
          sampleDriverContext(withVehicle: false),
        )
        ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
          sampleComputeRouteResponse(),
        );
      final feedItem = DriverWorkFeedItemDto.fromJson(
        sampleWorkFeedDeliveryItem(),
      );

      await pumpWithProviders(
        tester,
        DeliveryMissionMapScreen(
          tileProvider: FakeTileProvider(),
          missionId: 'shipment-1',
          scope: _scope,
          feedItem: feedItem,
        ),
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(
            FakeLocationRepository(),
          ),
        ],
      );

      expect(client.lastComputeRouteRequest?.vehicleMode, isNull);
    },
  );

  testWidgets(
    'driver context that fails to load (never delayed/blocked) still routes with vehicleMode null',
    (tester) async {
      final client = FakeDriverApiClient()
        ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(
          sampleMission(),
        )
        ..deliveryMissionIncidentsResponse = []
        ..driverContextFailure = const AppFailure(AppFailureType.server)
        ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
          sampleComputeRouteResponse(),
        );
      final feedItem = DriverWorkFeedItemDto.fromJson(
        sampleWorkFeedDeliveryItem(),
      );

      await pumpWithProviders(
        tester,
        DeliveryMissionMapScreen(
          tileProvider: FakeTileProvider(),
          missionId: 'shipment-1',
          scope: _scope,
          feedItem: feedItem,
        ),
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(
            FakeLocationRepository(),
          ),
        ],
      );

      expect(client.lastComputeRouteRequest?.vehicleMode, isNull);
      // The mission remains fully actionable even without driver context.
      expect(find.byType(PolylineLayer), findsOneWidget);
    },
  );
}
