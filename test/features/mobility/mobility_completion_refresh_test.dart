import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/features/availability/availability_repository.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/mobility/mobility_repository.dart';
import 'package:noki_driver_app/features/mobility/mobility_ride_screen.dart';
import 'package:noki_driver_app/features/work_feed/work_feed_repository.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

/// Mirrors delivery_completion_refresh_test.dart for the Mobility side
/// (mandate §23): transitioning a ride must invalidate `availabilityProvider`,
/// `currentRideProvider` (Home's "continue active ride" card) and
/// `workFeedProvider` (Work Feed's own separate read - the same class of gap
/// found live on-device for Delivery completion).
void main() {
  testWidgets('transitioning a ride invalidates and refetches availability and the current-ride provider', (tester) async {
    final client = FakeDriverApiClient()
      ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide())
      ..transitionMobilityRideResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide(status: 'DRIVER_EN_ROUTE'))
      ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(sampleAvailability())
      ..currentMobilityRideResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide())
      ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(sampleWorkFeedList())
      ..mobilityIncidentsResponse = DriverMobilityIncidentListResponseDto.fromJson({'items': [], 'total': 0, 'page': 1, 'pageSize': 25});

    final container = ProviderContainer(overrides: [driverApiClientProvider.overrideWithValue(client)]);
    addTearDown(container.dispose);

    container.listen(availabilityProvider(_scope), (_, _) {}, fireImmediately: true);
    container.listen(currentRideProvider(_scope), (_, _) {}, fireImmediately: true);
    container.listen(workFeedProvider(_scope), (_, _) {}, fireImmediately: true);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildNokiTheme(NokiColors.light, Brightness.light),
          home: const MobilityRideScreen(rideId: 'ride-1', scope: _scope),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final baselineAvailabilityCalls = client.driverAvailabilityCallCount;
    final baselineCurrentRideCalls = client.currentMobilityRideCallCount;
    final baselineWorkFeedCalls = client.driverWorkFeedCallCount;
    expect(baselineAvailabilityCalls, greaterThan(0));
    expect(baselineCurrentRideCalls, greaterThan(0));
    expect(baselineWorkFeedCalls, greaterThan(0));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Mark en route'));
    await tester.pumpAndSettle();

    expect(client.lastTransitionMobilityRideBody?.status, TransitionMobilityRideDtoStatus.driverEnRoute);
    expect(client.driverAvailabilityCallCount, greaterThan(baselineAvailabilityCalls));
    expect(client.currentMobilityRideCallCount, greaterThan(baselineCurrentRideCalls));
    expect(client.driverWorkFeedCallCount, greaterThan(baselineWorkFeedCalls));
  });
}
