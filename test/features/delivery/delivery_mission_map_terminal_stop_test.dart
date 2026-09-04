import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/location/location_permission_state.dart';
import 'package:noki_driver_app/core/location/location_repository.dart';
import 'package:noki_driver_app/core/location/gps_publisher.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/features/delivery/delivery_mission_map_screen.dart';
import 'package:noki_driver_app/features/delivery/delivery_repository.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_location_repository.dart';
import '../../fixtures/sample_responses.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  testWidgets(
    'stops publishing active-work location the instant the mission goes terminal, '
    'without waiting for the driver to navigate away',
    (tester) async {
      final client = FakeDriverApiClient()
        ..getOwnMissionResponse = DriverMissionResponseDto.fromJson(
          sampleMission(status: 'ASSIGNED'),
        )
        ..deliveryMissionIncidentsResponse = [];

      final container = ProviderContainer(
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          // Service-disabled sidesteps needing a real geolocator position
          // stream in this widget test; updateContext() itself doesn't
          // depend on permission state, only the actual stream call site
          // does, so the publisher's tracked context is still observable.
          locationRepositoryProvider.overrideWithValue(
            FakeLocationRepository(
              state: LocationPermissionState.serviceDisabled,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildNokiTheme(NokiColors.light, Brightness.light),
            supportedLocales: const [Locale('fr'), Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const DeliveryMissionMapScreen(
              missionId: 'shipment-1',
              scope: _scope,
              tileProvider: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Still an active mission: the map screen has handed the publisher
      // this mission id.
      final publisher = container.read(gpsPublisherControllerProvider);
      expect(publisher.context.activeMissionId, 'shipment-1');

      // Backend reports the mission delivered while the driver stays on
      // this same screen (no pop/navigate-away).
      client.getOwnMissionResponse = DriverMissionResponseDto.fromJson(
        sampleMission(status: 'DELIVERED'),
      );
      container.invalidate(missionDetailProvider('shipment-1'));
      await tester.pumpAndSettle();

      expect(publisher.context.activeMissionId, isNull);
    },
  );
}
