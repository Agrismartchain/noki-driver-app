import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/features/mobility/mobility_ride_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

void main() {
  testWidgets('a DRIVER_ASSIGNED ride only offers "mark en route" and "cancel", never "complete"', (tester) async {
    final client = FakeDriverApiClient()..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide());

    await pumpWithProviders(
      tester,
      const MobilityRideScreen(rideId: 'ride-1'),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.widgetWithText(ElevatedButton, 'Mark en route'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Cancel ride'), findsOneWidget);
    expect(find.text('Complete ride'), findsNothing);
    expect(find.text('Start ride'), findsNothing);
  });

  testWidgets('an IN_PROGRESS ride offers "complete" and "cancel", never "mark en route" again', (tester) async {
    final client = FakeDriverApiClient()
      ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide(status: 'IN_PROGRESS'));

    await pumpWithProviders(
      tester,
      const MobilityRideScreen(rideId: 'ride-1'),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.widgetWithText(ElevatedButton, 'Complete ride'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Cancel ride'), findsOneWidget);
    expect(find.text('Mark en route'), findsNothing);
  });

  testWidgets('a COMPLETED ride is terminal - no action buttons at all', (tester) async {
    final client = FakeDriverApiClient()
      ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide(status: 'COMPLETED'));

    await pumpWithProviders(
      tester,
      const MobilityRideScreen(rideId: 'ride-1'),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text('No actions available for this ride right now'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('tapping "mark en route" calls the transition endpoint with DRIVER_EN_ROUTE and refreshes', (tester) async {
    final client = FakeDriverApiClient()
      ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide())
      ..transitionMobilityRideResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide(status: 'DRIVER_EN_ROUTE'));

    await pumpWithProviders(
      tester,
      const MobilityRideScreen(rideId: 'ride-1'),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Mark en route'));
    await tester.pumpAndSettle();

    expect(client.lastTransitionMobilityRideBody?.status, TransitionMobilityRideDtoStatus.driverEnRoute);
  });
}
