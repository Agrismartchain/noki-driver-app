import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/work_feed/work_feed_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  testWidgets('a mixed feed renders Delivery and Ride cards as visually distinct types', (tester) async {
    final client = FakeDriverApiClient()
      ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson({
        'items': [sampleWorkFeedDeliveryItem(), sampleWorkFeedRideItem(), sampleWorkFeedOfferItem()],
        'total': 3,
        'page': 1,
        'pageSize': 25,
      });

    await pumpWithProviders(
      tester,
      const WorkFeedScreen(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    expect(find.byIcon(Icons.local_taxi_outlined), findsNWidgets(2));
  });

  testWidgets('the Delivery filter hides ride cards without changing the underlying feed', (tester) async {
    final client = FakeDriverApiClient()
      ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(sampleWorkFeedList());

    await pumpWithProviders(
      tester,
      const WorkFeedScreen(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    expect(find.byIcon(Icons.local_taxi_outlined), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Delivery'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    expect(find.byIcon(Icons.local_taxi_outlined), findsNothing);
  });

  testWidgets('shows a real empty state, not invented work, when the feed is empty', (tester) async {
    final client = FakeDriverApiClient()
      ..workFeedResponse = const DriverWorkFeedListResponseDto(items: [], total: 0, page: 1, pageSize: 25);

    await pumpWithProviders(
      tester,
      const WorkFeedScreen(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text('Nothing assigned right now'), findsOneWidget);
  });

  testWidgets('tapping a Delivery card navigates to the mission detail screen', (tester) async {
    final client = FakeDriverApiClient()
      ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson({
        'items': [sampleWorkFeedDeliveryItem()],
        'total': 1,
        'page': 1,
        'pageSize': 25,
      })
      ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(sampleMission());

    await pumpWithProviders(
      tester,
      const WorkFeedScreen(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    await tester.tap(find.byIcon(Icons.local_shipping_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Mission'), findsOneWidget);
    expect(client.lastGetOwnMissionId, 'shipment-1');
  });
}
