import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/features/availability/availability_repository.dart';
import 'package:noki_driver_app/features/delivery/delivery_mission_detail_screen.dart';
import 'package:noki_driver_app/features/delivery/delivery_repository.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/work_feed/work_feed_repository.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

/// Regression coverage for mandate DRIVER-APP-04 §15/§16/§23: completing a
/// Delivery must invalidate exactly the providers Home's "continue active
/// work" card and the Work Feed read (`availabilityProvider`,
/// `missionListByStatusProvider`, `workFeedProvider`), so a driver never has
/// to manually pull-to-refresh to see a just-completed delivery drop off.
/// `workFeedProvider` was added here after being caught stale live
/// on-device - the first two providers alone were not sufficient.
///
/// Uses a raw [ProviderContainer] with `container.listen(..., fireImmediately:
/// true)` on both providers *before* pumping the screen - this faithfully
/// reproduces the real app's shape, where `HomeShell`'s `IndexedStack` keeps
/// Home (and therefore its still-listening providers) alive underneath a
/// pushed Delivery detail screen, rather than actually testing nothing
/// because an unwatched `autoDispose` provider was already gone.
void main() {
  testWidgets('completing a delivery invalidates and refetches availability and the OUT_FOR_DELIVERY mission list', (tester) async {
    final client = FakeDriverApiClient()
      ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(sampleMission())
      ..deliveryMissionIncidentsResponse = []
      ..requestHandoffOtpResponse = DeliveryHandoffOtpChallengeResponseDto.fromJson(sampleOtpChallenge())
      ..verifyHandoffOtpResponse = DeliveryHandoffOtpVerificationResponseDto.fromJson(sampleOtpVerification())
      ..completeMissionResponse = DriverMissionCompletionResponseDto.fromJson(sampleMissionCompletion())
      ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(sampleAvailability())
      ..listOwnMissionsResponse = DriverMissionListResponseDto.fromJson(sampleMissionList())
      ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(sampleWorkFeedList());

    final container = ProviderContainer(overrides: [driverApiClientProvider.overrideWithValue(client)]);
    addTearDown(container.dispose);

    // Simulates Home's _ActiveWorkAndTrackingCard and the Work Feed screen
    // already watching these providers in the background while this screen
    // is pushed on top.
    container.listen(availabilityProvider(_scope), (_, _) {}, fireImmediately: true);
    container.listen(missionListByStatusProvider((_scope, 'OUT_FOR_DELIVERY')), (_, _) {}, fireImmediately: true);
    container.listen(workFeedProvider(_scope), (_, _) {}, fireImmediately: true);

    tester.view.physicalSize = const Size(400, 2400) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildNokiTheme(NokiColors.light, Brightness.light),
          home: const DeliveryMissionDetailScreen(missionId: 'shipment-1', scope: _scope),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final baselineAvailabilityCalls = client.driverAvailabilityCallCount;
    final baselineMissionListCalls = client.listOwnMissionsCallCount;
    final baselineWorkFeedCalls = client.driverWorkFeedCallCount;
    expect(baselineAvailabilityCalls, greaterThan(0));
    expect(baselineMissionListCalls, greaterThan(0));
    expect(baselineWorkFeedCalls, greaterThan(0));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Request handoff code'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Verify code'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Complete mission'));
    await tester.pumpAndSettle();

    expect(client.completeMissionCallCount, 1);
    expect(client.driverAvailabilityCallCount, greaterThan(baselineAvailabilityCalls));
    expect(client.listOwnMissionsCallCount, greaterThan(baselineMissionListCalls));
    expect(client.driverWorkFeedCallCount, greaterThan(baselineWorkFeedCalls));
  });
}
