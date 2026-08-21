import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/features/driver_context/home_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

void main() {
  testWidgets(
    'renders the driver greeting, assigned vehicle and work feed count',
    (tester) async {
      final client = FakeDriverApiClient()
        ..driverContextResponse = DriverContextResponseDto.fromJson(
          sampleDriverContext(),
        )
        ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(
          sampleAvailability(),
        )
        ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(
          sampleWorkFeedList(),
        );

      await pumpWithProviders(
        tester,
        const HomeScreen(),
        overrides: [driverApiClientProvider.overrideWithValue(client)],
      );

      expect(find.text('Hello, Amine Tazi'), findsOneWidget);
      expect(find.textContaining('Dacia Logan'), findsOneWidget);
      expect(find.text('2 open work items'), findsOneWidget);
    },
  );

  testWidgets(
    'shows a real empty state - no vehicle - when the actor has none assigned',
    (tester) async {
      final client = FakeDriverApiClient()
        ..driverContextResponse = DriverContextResponseDto.fromJson(
          sampleDriverContext(withVehicle: false),
        )
        ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(
          sampleAvailability(),
        )
        ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(
          sampleWorkFeedList(),
        );

      await pumpWithProviders(
        tester,
        const HomeScreen(),
        overrides: [driverApiClientProvider.overrideWithValue(client)],
      );

      expect(find.text('No vehicle assigned yet'), findsOneWidget);
    },
  );

  testWidgets(
    'shows an error view with retry when the driver context call fails',
    (tester) async {
      final client = FakeDriverApiClient()
        ..driverContextFailure = const AppFailure(AppFailureType.server);

      await pumpWithProviders(
        tester,
        const HomeScreen(),
        overrides: [driverApiClientProvider.overrideWithValue(client)],
      );

      expect(
        find.text('Something went wrong on our side. Try again shortly.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    },
  );

  testWidgets(
    'an active ride surfaces a one-tap "continue" card instead of the idle tracking line',
    (tester) async {
      final client = FakeDriverApiClient()
        ..driverContextResponse = DriverContextResponseDto.fromJson(
          sampleDriverContext(),
        )
        ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(
          sampleAvailability(),
        )
        ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(
          sampleWorkFeedList(),
        )
        ..currentMobilityRideResponse = MobilityRideDetailDto.fromJson(
          sampleMobilityRide(),
        );

      await pumpWithProviders(
        tester,
        const HomeScreen(),
        overrides: [driverApiClientProvider.overrideWithValue(client)],
      );

      expect(find.text('Continue active ride'), findsOneWidget);
      expect(find.text('Not tracking - offline'), findsNothing);
    },
  );

  testWidgets(
    'no active work and no availability shows the idle tracking line, not a continue card',
    (tester) async {
      final client = FakeDriverApiClient()
        ..driverContextResponse = DriverContextResponseDto.fromJson(
          sampleDriverContext(),
        )
        ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(
          sampleAvailability(
            activeDeliveryMissionCount: 0,
            activeMobilityRideCount: 0,
          ),
        )
        ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(
          sampleWorkFeedList(),
        );

      await pumpWithProviders(
        tester,
        const HomeScreen(),
        overrides: [driverApiClientProvider.overrideWithValue(client)],
      );

      expect(find.text('Continue active ride'), findsNothing);
      expect(find.text('Continue active delivery'), findsNothing);
    },
  );

  testWidgets(
    'dark home header renders below the top safe area and remains visible in Arabic RTL',
    (tester) async {
      final client = FakeDriverApiClient()
        ..driverContextResponse = DriverContextResponseDto.fromJson(
          sampleDriverContext(),
        )
        ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(
          sampleAvailability(),
        )
        ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(
          sampleWorkFeedList(),
        );

      const topInset = 44.0;

      await pumpWithProviders(
        tester,
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(top: topInset),
            viewPadding: EdgeInsets.only(top: topInset),
          ),
          child: const HomeScreen(),
        ),
        locale: const Locale('ar'),
        theme: buildNokiTheme(NokiColors.dark, Brightness.dark),
        overrides: [driverApiClientProvider.overrideWithValue(client)],
      );

      final greeting = AppLocalizations.of(
        tester.element(find.byType(HomeScreen)),
      ).homeGreeting('Amine Tazi');
      final greetingFinder = find.text(greeting);

      expect(greetingFinder, findsOneWidget);
      expect(
        tester.getTopLeft(greetingFinder).dy,
        greaterThanOrEqualTo(topInset),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
