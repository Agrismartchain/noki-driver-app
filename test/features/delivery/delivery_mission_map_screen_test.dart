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

void main() {
  testWidgets('an out-for-delivery mission shows its status and the OTP next-action hint on the map bottom sheet', (tester) async {
    final client = FakeDriverApiClient()
      ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(sampleMission())
      ..deliveryMissionIncidentsResponse = [];
    final feedItem = DriverWorkFeedItemDto.fromJson(sampleWorkFeedDeliveryItem());

    await pumpWithProviders(
      tester,
      DeliveryMissionMapScreen(
      tileProvider: FakeTileProvider(),
      missionId: 'shipment-1', scope: _scope, feedItem: feedItem),
      overrides: [
        driverApiClientProvider.overrideWithValue(client),
        locationRepositoryProvider.overrideWithValue(FakeLocationRepository()),
      ],
    );

    expect(find.text('Out for delivery'), findsWidgets);
    expect(find.text('Request the handoff code to complete this delivery'), findsOneWidget);
  });

  testWidgets('an assigned (not yet out-for-delivery) mission does not offer the OTP hint', (tester) async {
    final client = FakeDriverApiClient()
      ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(sampleMission(status: 'ASSIGNED'))
      ..deliveryMissionIncidentsResponse = [];

    await pumpWithProviders(
      tester,
      DeliveryMissionMapScreen(
      tileProvider: FakeTileProvider(),
      missionId: 'shipment-1', scope: _scope),
      overrides: [
        driverApiClientProvider.overrideWithValue(client),
        locationRepositoryProvider.overrideWithValue(FakeLocationRepository()),
      ],
    );

    expect(find.text('Request the handoff code to complete this delivery'), findsNothing);
  });
}
