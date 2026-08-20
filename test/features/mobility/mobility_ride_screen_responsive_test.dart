import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/mobility/mobility_ride_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

/// The new Mobility incidents section (mandate §22) adds a
/// DropdownButtonFormField whose widest item ("Customer complaint") already
/// caused one real overflow this phase (fixed with `isExpanded: true`) -
/// this is the regression guard, at the narrowest supported width, in every
/// shipped locale including Arabic RTL, and in dark mode.
void main() {
  Future<void> pumpTall(WidgetTester tester, Widget child, {required List<Override> overrides, Locale locale = const Locale('en'), ThemeData? theme}) async {
    tester.view.physicalSize = const Size(320, 1400) * tester.view.devicePixelRatio;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await pumpWithProviders(tester, child, overrides: overrides, locale: locale, theme: theme);
  }

  for (final locale in [const Locale('en'), const Locale('fr'), const Locale('ar')]) {
    testWidgets('ride screen with incidents section does not overflow at 320dp (${locale.languageCode})', (tester) async {
      final client = FakeDriverApiClient()
        ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide())
        ..mobilityIncidentsResponse = DriverMobilityIncidentListResponseDto.fromJson({
          'items': [sampleMobilityIncident()],
          'total': 1,
          'page': 1,
          'pageSize': 25,
        });

      await pumpTall(
        tester,
        const MobilityRideScreen(rideId: 'ride-1', scope: _scope),
        overrides: [driverApiClientProvider.overrideWithValue(client)],
        locale: locale,
      );

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ride screen with incidents section renders under dark theme without error', (tester) async {
    final client = FakeDriverApiClient()
      ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(sampleMobilityRide())
      ..mobilityIncidentsResponse = DriverMobilityIncidentListResponseDto.fromJson({'items': [], 'total': 0, 'page': 1, 'pageSize': 25});

    await pumpTall(
      tester,
      const MobilityRideScreen(rideId: 'ride-1', scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
      theme: buildNokiTheme(NokiColors.dark, Brightness.dark),
    );

    expect(tester.takeException(), isNull);
  });
}
