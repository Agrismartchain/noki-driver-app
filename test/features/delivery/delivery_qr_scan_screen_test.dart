import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/features/delivery/delivery_qr_entry_screen.dart';
import 'package:noki_driver_app/features/delivery/delivery_qr_scan_screen.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';

import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  testWidgets('renders without throwing when the platform camera is unavailable in the test host', (tester) async {
    await pumpWithProviders(tester, const DeliveryQrScanScreen(scope: _scope));
    // The widget-test host has no real camera platform implementation, so
    // this exercises the honest error path (errorBuilder), not a crash -
    // mandate §27 "must not hang", proven by simply not throwing here.
    expect(tester.takeException(), isNull);
    expect(find.byType(DeliveryQrScanScreen), findsOneWidget);
  });

  testWidgets('the manual-entry action navigates to DeliveryQrEntryScreen', (tester) async {
    await pumpWithProviders(tester, const DeliveryQrScanScreen(scope: _scope));

    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(DeliveryQrEntryScreen), findsOneWidget);
  });
}
