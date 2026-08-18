import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/vehicles/vehicles_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/test_harness.dart';

// Regression coverage for DRIVER-APP-01R V-1: a vehicle row with a long
// status (PENDING_VALIDATION -> "En attente de validation" in French) and
// long make/model/plate must never overflow, at any of the widths this app
// targets, in any locale/direction, in either theme.
const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

Map<String, dynamic> _longVehicleListJson() => {
      'items': [
        {
          'id': 'vehicle-long-1',
          'type': 'MOTORCYCLE',
          'plate': 'CASABLANCA-999887-XZ-6',
          'make': 'Kawasaki International Motors',
          'model': 'Ninja ZX-25R Performance Edition',
          'status': 'PENDING_VALIDATION',
          'allowedServiceTypes': ['TAXI_MOTO'],
          'organizationId': 'org-1',
          'countryId': 'country-1',
          'countryCode': 'MA',
          'code': 'VEH-999',
          'updatedAt': '2026-08-18T10:00:00.000Z',
        },
      ],
      'total': 1,
      'page': 1,
      'pageSize': 25,
    };

Future<void> _pumpAtWidth(
  WidgetTester tester, {
  required double width,
  Locale locale = const Locale('fr'),
}) async {
  tester.view.physicalSize = Size(width, 800) * tester.view.devicePixelRatio;
  addTearDown(tester.view.reset);

  final client = FakeDriverApiClient()..vehiclesResponse = DriverVehicleListResponseDto.fromJson(_longVehicleListJson());

  await pumpWithProviders(
    tester,
    const VehiclesScreen(scope: _scope),
    overrides: [driverApiClientProvider.overrideWithValue(client)],
    locale: locale,
  );
}

void main() {
  for (final width in [320.0, 360.0, 390.0, 430.0]) {
    testWidgets('no overflow at ${width.toInt()}dp with a long make/model/plate and PENDING_VALIDATION status',
        (tester) async {
      await _pumpAtWidth(tester, width: width);

      // A RenderFlex overflow (or any other layout error) reports through
      // FlutterError - if the layout is broken, it surfaces here instead of
      // silently passing.
      expect(tester.takeException(), isNull);

      // The exact backend status is still shown in full - never truncated
      // or replaced by a shortened, non-contractual value.
      expect(find.text('En attente de validation'), findsOneWidget);
    });
  }

  testWidgets('no overflow in Arabic RTL at 360dp with a long status', (tester) async {
    await _pumpAtWidth(tester, width: 360, locale: const Locale('ar'));

    expect(tester.takeException(), isNull);
    expect(find.text('بانتظار التحقق'), findsOneWidget);
  });

  testWidgets('no overflow in dark mode at 360dp with a long status', (tester) async {
    tester.view.physicalSize = const Size(360, 800) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);

    final client = FakeDriverApiClient()..vehiclesResponse = DriverVehicleListResponseDto.fromJson(_longVehicleListJson());

    await pumpWithProviders(
      tester,
      const VehiclesScreen(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
      theme: buildNokiTheme(NokiColors.dark, Brightness.dark),
    );

    expect(tester.takeException(), isNull);
  });
}
