import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/features/delivery/delivery_mission_detail_screen.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  // This screen is a long scrollable list of section cards; the default
  // test surface is too short to realize every sliver child, so widen it
  // for every test in this file rather than scrolling case by case.
  Future<void> pumpTall(
    WidgetTester tester,
    Widget child, {
    required List<Override> overrides,
    Locale locale = const Locale('en'),
    ThemeData? theme,
  }) async {
    tester.view.physicalSize = const Size(400, 2400) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    await pumpWithProviders(tester, child, overrides: overrides, locale: locale, theme: theme);
  }

  testWidgets('renders dropoff/customer/status from the mission, and a real empty pickup without a feed item', (tester) async {
    final client = FakeDriverApiClient()
      ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(sampleMission())
      ..deliveryMissionIncidentsResponse = [];

    await pumpTall(
      tester,
      const DeliveryMissionDetailScreen(missionId: 'shipment-1', scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text('Nadia Idrissi'), findsOneWidget);
    expect(find.text('4 Rue Zerktouni'), findsOneWidget);
    expect(find.text('Out for delivery'), findsWidgets);
    // No Work Feed item was passed in, so Pickup honestly says so instead of
    // guessing - the mission detail endpoint has no pickup field at all.
    expect(find.text('Not available for this mission'), findsOneWidget);
    // No currency code is available on the raw mission DTO either.
    expect(find.text('Currency code not available for this amount'), findsOneWidget);
  });

  testWidgets('a feed item in hand shows pickup and a currency-coded amount', (tester) async {
    final client = FakeDriverApiClient()
      ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(sampleMission())
      ..deliveryMissionIncidentsResponse = [];
    final feedItem = DriverWorkFeedItemDto.fromJson(sampleWorkFeedDeliveryItem());

    await pumpTall(
      tester,
      DeliveryMissionDetailScreen(missionId: 'shipment-1', scope: _scope, feedItem: feedItem),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text('Warehouse'), findsOneWidget);
    expect(find.text('120.00 MAD'), findsOneWidget);
  });

  testWidgets('the Complete action is unavailable until the mission is out for delivery', (tester) async {
    final client = FakeDriverApiClient()
      ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(sampleMission(status: 'ASSIGNED'))
      ..deliveryMissionIncidentsResponse = [];

    await pumpTall(
      tester,
      const DeliveryMissionDetailScreen(missionId: 'shipment-1', scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text('This mission can be completed once it is out for delivery'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Complete mission'), findsNothing);
  });

  testWidgets('renders correctly in Arabic RTL', (tester) async {
    final client = FakeDriverApiClient()
      ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(sampleMission())
      ..deliveryMissionIncidentsResponse = [];

    await pumpTall(
      tester,
      const DeliveryMissionDetailScreen(missionId: 'shipment-1', scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
      locale: const Locale('ar'),
    );

    expect(Directionality.of(tester.element(find.byType(DeliveryMissionDetailScreen))), TextDirection.rtl);
    expect(find.text('Nadia Idrissi'), findsOneWidget);
  });

  testWidgets('renders under the dark theme without error', (tester) async {
    final client = FakeDriverApiClient()
      ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(sampleMission())
      ..deliveryMissionIncidentsResponse = [];

    await pumpTall(
      tester,
      const DeliveryMissionDetailScreen(missionId: 'shipment-1', scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
      theme: buildNokiTheme(NokiColors.dark, Brightness.dark),
    );

    expect(find.text('Nadia Idrissi'), findsOneWidget);
  });

  testWidgets('shows the real backend error, not a raw exception, when the mission fails to load', (tester) async {
    final client = FakeDriverApiClient()..getOwnMissionFailure = const AppFailure(AppFailureType.notFound);

    await pumpTall(
      tester,
      const DeliveryMissionDetailScreen(missionId: 'missing', scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text("We couldn't find that."), findsOneWidget);
  });
}
