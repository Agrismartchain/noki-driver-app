import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/location/location_permission_gate.dart';
import 'package:noki_driver_app/core/location/location_permission_state.dart';
import 'package:noki_driver_app/core/location/location_repository.dart';

import '../../fixtures/fake_location_repository.dart';
import '../../fixtures/test_harness.dart';

void main() {
  testWidgets('granted permission renders the wrapped content', (tester) async {
    final fake = FakeLocationRepository(state: LocationPermissionState.granted);
    await pumpWithProviders(
      tester,
      LocationPermissionGate(builder: (_) => const Text('map content')),
      overrides: [locationRepositoryProvider.overrideWithValue(fake)],
    );

    expect(find.text('map content'), findsOneWidget);
  });

  testWidgets('denied-once shows a rationale with a grant action, not the map', (tester) async {
    final fake = FakeLocationRepository(state: LocationPermissionState.deniedOnce);
    await pumpWithProviders(
      tester,
      LocationPermissionGate(builder: (_) => const Text('map content')),
      overrides: [locationRepositoryProvider.overrideWithValue(fake)],
    );

    expect(find.text('map content'), findsNothing);
    expect(find.text('Allow location access'), findsOneWidget);
  });

  testWidgets('denied-forever offers only "open settings", never re-prompts', (tester) async {
    final fake = FakeLocationRepository(state: LocationPermissionState.deniedForever);
    await pumpWithProviders(
      tester,
      LocationPermissionGate(builder: (_) => const Text('map content')),
      overrides: [locationRepositoryProvider.overrideWithValue(fake)],
    );

    expect(find.text('map content'), findsNothing);
    expect(find.text('Open settings'), findsOneWidget);
    expect(find.text('Allow location access'), findsNothing);

    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(fake.openSettingsCalled, isTrue);
  });

  testWidgets('service disabled is distinguished from a denied permission', (tester) async {
    final fake = FakeLocationRepository(state: LocationPermissionState.serviceDisabled);
    await pumpWithProviders(
      tester,
      LocationPermissionGate(builder: (_) => const Text('map content')),
      overrides: [locationRepositoryProvider.overrideWithValue(fake)],
    );

    expect(find.text('Location services are turned off on this device. Enable them to use the map.'), findsOneWidget);
  });

  testWidgets('tapping "allow" re-requests and reveals the content once granted', (tester) async {
    final fake = FakeLocationRepository(state: LocationPermissionState.deniedOnce);
    await pumpWithProviders(
      tester,
      LocationPermissionGate(builder: (_) => const Text('map content')),
      overrides: [locationRepositoryProvider.overrideWithValue(fake)],
    );

    await tester.tap(find.text('Allow location access'));
    await tester.pumpAndSettle();

    expect(find.text('map content'), findsOneWidget);
  });
}
