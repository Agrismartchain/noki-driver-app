import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/connectivity/connectivity_status.dart';
import 'package:noki_driver_app/core/connectivity/offline_banner.dart';

import '../../fixtures/test_harness.dart';

const _offlineMessage = "You're offline. Some information may be out of date.";

/// [OfflineBanner] and its map-screen counterpart [NetworkStatusChip] had no
/// prior coverage at all (see the night QA report) - this locks in the one
/// behavior that matters for the "recovery after network loss" scenario:
/// both stay invisible while online/unknown, and both surface the same
/// offline message once the link genuinely drops.
void main() {
  Future<void> pump(WidgetTester tester, NetworkStatus status, Widget child) {
    return pumpWithProviders(
      tester,
      child,
      overrides: [
        networkStatusProvider.overrideWith((ref) => Stream.value(status)),
      ],
    );
  }

  testWidgets('OfflineBanner is invisible while online', (tester) async {
    await pump(tester, NetworkStatus.online, const OfflineBanner());
    expect(find.text(_offlineMessage), findsNothing);
  });

  testWidgets('OfflineBanner shows the offline message once the link drops', (
    tester,
  ) async {
    await pump(tester, NetworkStatus.offline, const OfflineBanner());
    expect(find.text(_offlineMessage), findsOneWidget);
  });

  testWidgets('NetworkStatusChip is invisible while online', (tester) async {
    await pump(tester, NetworkStatus.online, const NetworkStatusChip());
    expect(find.text(_offlineMessage), findsNothing);
  });

  testWidgets(
    'NetworkStatusChip surfaces the same offline message on the map screens',
    (tester) async {
      await pump(tester, NetworkStatus.offline, const NetworkStatusChip());
      expect(find.text(_offlineMessage), findsOneWidget);
    },
  );
}
