import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/features/delivery/delivery_mission_detail_screen.dart';
import 'package:noki_driver_app/features/delivery/delivery_qr_entry_screen.dart';
import 'package:noki_driver_app/features/delivery/delivery_qr_scan_screen.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  testWidgets('submitting a valid token navigates to the resolved mission detail', (tester) async {
    final client = FakeDriverApiClient()..scanMissionQrResponse = DriverMissionResponseDto.fromJson(sampleMission());

    await pumpWithProviders(
      tester,
      const DeliveryQrEntryScreen(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    await tester.enterText(find.byType(TextField), 'dqr_${'a' * 40}');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
    await tester.pumpAndSettle();

    expect(find.byType(DeliveryMissionDetailScreen), findsOneWidget);
  });

  testWidgets('shows the real backend error for an invalid/expired token, not a raw exception', (tester) async {
    final client = FakeDriverApiClient()..scanMissionQrFailure = const AppFailure(AppFailureType.notFound);

    await pumpWithProviders(
      tester,
      const DeliveryQrEntryScreen(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    await tester.enterText(find.byType(TextField), 'dqr_${'a' * 40}');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
    await tester.pumpAndSettle();

    expect(find.text("We couldn't find that."), findsOneWidget);
  });

  testWidgets('the camera action navigates to DeliveryQrScanScreen', (tester) async {
    await pumpWithProviders(tester, const DeliveryQrEntryScreen(scope: _scope));

    await tester.tap(find.byIcon(Icons.qr_code_scanner_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(DeliveryQrScanScreen), findsOneWidget);
  });
}
