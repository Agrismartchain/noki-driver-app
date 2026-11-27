import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:noki_driver_app/app/home_shell.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/api/mfa/mfa_models.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/location/location_permission_gate.dart';
import 'package:noki_driver_app/core/location/location_permission_state.dart';
import 'package:noki_driver_app/core/location/location_repository.dart';
import 'package:noki_driver_app/core/storage/storage_providers.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/core/ui/noki_ui.dart';
import 'package:noki_driver_app/features/auth/auth_providers.dart';
import 'package:noki_driver_app/features/auth/auth_state.dart';
import 'package:noki_driver_app/features/auth/mfa_enroll_screen.dart';
import 'package:noki_driver_app/features/auth/mfa_recovery_codes_screen.dart';
import 'package:noki_driver_app/features/auth/mfa_verify_screen.dart';
import 'package:noki_driver_app/features/delivery/delivery_history_screen.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/driver_context/home_screen.dart';
import 'package:noki_driver_app/features/map/map_view.dart';
import 'package:noki_driver_app/features/mobility/mobility_history_screen.dart';
import 'package:noki_driver_app/features/settings/settings_screen.dart';
import 'package:noki_driver_app/features/work_feed/work_feed_screen.dart';

import '../fixtures/fake_driver_api_client.dart';
import '../fixtures/fake_location_repository.dart';
import '../fixtures/fake_session_storage.dart';
import '../fixtures/fake_tile_provider.dart';
import '../fixtures/sample_responses.dart';
import '../fixtures/test_harness.dart';

const _cgScope = DriverScope(organizationId: 'org-cg-1', countryCode: 'CG');

double _contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

Map<String, dynamic> _congoDriverContext({bool withDeliveryProfile = true}) => {
  'actorId': 'actor-cg-1',
  'displayName': 'Jean-Luc Mbemba',
  'email': 'jeanluc@noki.cg',
  'effectivePermissionCodes': ['driver.profile.read.own'],
  'capabilities': ['driver.profile.read.own'],
  'profiles': [
    {
      'organizationId': 'org-cg-1',
      'organizationName': 'NOKI Brazzaville',
      'countryId': 'country-cg',
      'countryCode': 'CG',
      'deliveryProfileId': withDeliveryProfile ? 'delivery-cg-1' : null,
      'deliveryStatus': withDeliveryProfile ? 'ACTIVE' : null,
      'mobilityProfileId': 'mobility-cg-1',
      'mobilityOnboardingStatus': 'APPROVED',
      'mobilityOperationalStatus': 'ACTIVE',
      'mobilityAvailabilityStatus': 'OFFLINE',
      'serviceTypes': ['TAXI', 'TAXI_MOTO', 'COURIER', 'CARGO'],
      'assignedVehicle': {
        'id': 'veh-cg-1',
        'type': 'CAR',
        'plate': 'BZV-204-CG',
        'make': 'Toyota',
        'model': 'Corolla',
        'status': 'ACTIVE',
        'allowedServiceTypes': ['TAXI', 'CARGO'],
      },
    },
  ],
};

Map<String, dynamic> _multiServiceWorkFeed() => {
  'items': [
    {
      ...sampleWorkFeedDeliveryItem(),
      'workItemId': 'work-del-1',
      'workType': 'DELIVERY',
      'serviceType': 'DELIVERY',
      'amount': {'amount': '12 500', 'currencyCode': 'XAF'},
      'dropoff': {
        'label': 'Client',
        'addressLine1': 'Avenue Amilcar Cabral, Brazzaville',
        'latitude': -4.26,
        'longitude': 15.25,
      },
    },
    {
      ...sampleWorkFeedRideItem(),
      'workItemId': 'work-taxi-1',
      'workType': 'RIDE',
      'serviceType': 'TAXI',
      'amount': {'amount': '2 500', 'currencyCode': 'XAF'},
      'dropoff': {
        'label': 'Dropoff',
        'addressLine1': 'Rond-point Poto-Poto',
        'latitude': -4.27,
        'longitude': 15.27,
      },
    },
    {
      ...sampleWorkFeedOfferItem(),
      'workItemId': 'work-moto-1',
      'workType': 'RIDE',
      'serviceType': 'TAXI_MOTO',
      'amount': {'amount': '1 000', 'currencyCode': 'XAF'},
      'dropoff': {
        'label': 'Dropoff',
        'addressLine1': 'Marché Total Bacongo',
        'latitude': -4.28,
        'longitude': 15.24,
      },
    },
    {
      ...sampleWorkFeedOfferItem(),
      'workItemId': 'work-courier-1',
      'workType': 'RIDE',
      'serviceType': 'COURIER',
      'amount': {'amount': '3 000', 'currencyCode': 'XAF'},
      'dropoff': {
        'label': 'Dropoff',
        'addressLine1': 'Plateau des 15 Ans',
        'latitude': -4.25,
        'longitude': 15.26,
      },
    },
    {
      ...sampleWorkFeedOfferItem(),
      'workItemId': 'work-cargo-1',
      'workType': 'RIDE',
      'serviceType': 'CARGO',
      'amount': {'amount': '18 000', 'currencyCode': 'XAF'},
      'dropoff': {
        'label': 'Dropoff',
        'addressLine1': 'Zone Industrielle Mpila',
        'latitude': -4.24,
        'longitude': 15.29,
      },
    },
  ],
  'total': 5,
  'page': 1,
  'pageSize': 25,
};

Future<void> _settleBootstrap(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  while (container.read(authControllerProvider).status ==
      AuthStatus.bootstrapping) {
    await tester.pump();
  }
}

void main() {
  group('P0 Home embedded map, scroll & GPS resume', () {
    testWidgets(
      'Home shows NOKI logo next to greeting, embedded map immediately, and dragging on the map scrolls to the last card',
      (tester) async {
        tester.view.physicalSize = const Size(360, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final client = FakeDriverApiClient()
          ..driverContextResponse = DriverContextResponseDto.fromJson(
            _congoDriverContext(),
          )
          ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(
            sampleAvailability(),
          )
          ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(
            _multiServiceWorkFeed(),
          );
        final location = FakeLocationRepository(
          state: LocationPermissionState.granted,
        )..position = Position(
          latitude: -4.2634,
          longitude: 15.2429,
          timestamp: DateTime(2026, 11, 27),
          accuracy: 8,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );

        await pumpWithProviders(
          tester,
          const HomeScreen(),
          locale: const Locale('fr'),
          overrides: [
            driverApiClientProvider.overrideWithValue(client),
            locationRepositoryProvider.overrideWithValue(location),
          ],
        );

        expect(find.byKey(const Key('home-noki-logo')), findsOneWidget);
        expect(find.text('Bonjour, Jean-Luc Mbemba'), findsOneWidget);
        expect(find.byKey(const Key('home-embedded-map')), findsOneWidget);
        expect(find.byType(FlutterMap), findsOneWidget);
        expect(
          find.textContaining('NOKI Brazzaville (CG)'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('noki-map-marker-driver')), findsOneWidget);

        // Dragging vertically starting ON the embedded map must scroll Home
        // instead of being stolen by flutter_map's gesture recognizer.
        final homeScrollable = find.descendant(
          of: find.byKey(const Key('home-scroll-view')),
          matching: find.byType(Scrollable),
        );
        final initialOffset = tester
            .state<ScrollableState>(homeScrollable)
            .position
            .pixels;
        expect(initialOffset, 0);

        await tester.drag(
          find.byKey(const Key('home-embedded-map')),
          const Offset(0, -240),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        final afterMapDragOffset = tester
            .state<ScrollableState>(homeScrollable)
            .position
            .pixels;
        expect(
          afterMapDragOffset,
          greaterThan(100),
          reason: 'Dragging vertically on the embedded Home map must scroll Home',
        );

        await tester.scrollUntilVisible(
          find.byKey(const Key('home-work-feed-summary-card')),
          250,
          scrollable: homeScrollable,
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('home-work-feed-summary-card')),
          findsOneWidget,
        );
        expect(
          tester.getBottomLeft(
            find.byKey(const Key('home-work-feed-summary-card')),
          ).dy,
          lessThanOrEqualTo(720),
        );
      },
    );

    testWidgets(
      'GPS banner opens location settings when disabled and refreshes map & banner on app resume',
      (tester) async {
        final client = FakeDriverApiClient()
          ..driverContextResponse = DriverContextResponseDto.fromJson(
            _congoDriverContext(),
          )
          ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(
            sampleAvailability(),
          )
          ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(
            _multiServiceWorkFeed(),
          );
        final location = FakeLocationRepository(
          state: LocationPermissionState.serviceDisabled,
        );

        await pumpWithProviders(
          tester,
          const HomeScreen(),
          locale: const Locale('fr'),
          overrides: [
            driverApiClientProvider.overrideWithValue(client),
            locationRepositoryProvider.overrideWithValue(location),
          ],
        );

        expect(find.byKey(const Key('home-gps-banner')), findsOneWidget);
        expect(find.text('Activer le GPS'), findsOneWidget);
        expect(find.byKey(const Key('noki-map-marker-driver')), findsNothing);

        await tester.tap(find.text('Activer le GPS'));
        await tester.pumpAndSettle();
        expect(location.openLocationSettingsCalled, isTrue);

        // Driver turns GPS on in Android Settings and returns to the app.
        location.state = LocationPermissionState.granted;
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('home-gps-banner')), findsNothing);
        expect(find.byKey(const Key('noki-map-marker-driver')), findsOneWidget);
      },
    );

    testWidgets(
      'LocationPermissionGate re-checks permission on resume after returning from Settings',
      (tester) async {
        final fake = FakeLocationRepository(
          state: LocationPermissionState.serviceDisabled,
        );
        await pumpWithProviders(
          tester,
          LocationPermissionGate(builder: (_) => const Text('live map ready')),
          overrides: [locationRepositoryProvider.overrideWithValue(fake)],
        );

        expect(find.text('Enable GPS'), findsOneWidget);
        await tester.tap(find.text('Enable GPS'));
        await tester.pumpAndSettle();
        expect(fake.openLocationSettingsCalled, isTrue);

        fake.state = LocationPermissionState.granted;
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        expect(find.text('live map ready'), findsOneWidget);
      },
    );
  });

  group('P0 HomeShell navigation, bottom bar & system inset non-overlap', () {
    testWidgets(
      'last element of Home, Work, and Profile sits cleanly above bottom nav bar with system insets',
      (tester) async {
        tester.view.physicalSize = const Size(360, 740);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final client = FakeDriverApiClient()
          ..driverContextResponse = DriverContextResponseDto.fromJson(
            _congoDriverContext(),
          )
          ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(
            sampleAvailability(),
          )
          ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(
            _multiServiceWorkFeed(),
          );
        final storage = FakeSecureSessionStorage();
        await storage.writeAccessToken('access-token');
        await storage.writeRefreshToken('refresh-token');
        final location = FakeLocationRepository(
          state: LocationPermissionState.granted,
        );

        await pumpWithProviders(
          tester,
          const MediaQuery(
            data: MediaQueryData(
              size: Size(360, 740),
              padding: EdgeInsets.only(top: 32, bottom: 24),
              viewPadding: EdgeInsets.only(top: 32, bottom: 24),
            ),
            child: HomeShell(),
          ),
          locale: const Locale('fr'),
          theme: buildNokiTheme(NokiColors.dark, Brightness.dark),
          overrides: [
            driverApiClientProvider.overrideWithValue(client),
            secureSessionStorageProvider.overrideWithValue(storage),
            locationRepositoryProvider.overrideWithValue(location),
          ],
        );

        final shellScaffold = tester.widget<Scaffold>(
          find.byType(Scaffold).first,
        );
        expect(shellScaffold.extendBody, isFalse);

        final navBarTop = tester.getTopLeft(find.text('Accueil')).dy;

        // 1) Home tab: scroll to the last card and verify it is above nav bar.
        await tester.scrollUntilVisible(
          find.byKey(const Key('home-work-feed-summary-card')),
          250,
          scrollable: find.descendant(
            of: find.byKey(const Key('home-scroll-view')),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.pumpAndSettle();
        final homeLastBottom = tester
            .getBottomLeft(find.byKey(const Key('home-work-feed-summary-card')))
            .dy;
        expect(homeLastBottom, lessThanOrEqualTo(navBarTop));

        // 2) Work tab: switch via bottom nav and verify last card is reachable.
        await tester.tap(find.text('Travail').last);
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Zone Industrielle Mpila'),
          250,
          scrollable: find.descendant(
            of: find.byKey(const Key('work-feed-list')),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.text('Zone Industrielle Mpila')).dy,
          lessThanOrEqualTo(navBarTop),
        );

        // 3) Profile tab: switch via bottom nav and verify Logout button is
        // cleanly above the bottom nav bar.
        await tester.tap(find.text('Profil').last);
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const Key('profile-logout-button')),
          250,
          scrollable: find.descendant(
            of: find.byKey(const Key('profile-scroll-view')),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.byKey(const Key('profile-logout-button'))).dy,
          lessThanOrEqualTo(navBarTop),
        );
      },
    );
  });

  group('P0 Theme readability (light & dark) and Profile null delivery fix', () {
    test('offline badge and dark chrome ink preserve readable contrast in both themes', () {
      expect(
        _contrastRatio(NokiColors.dark.offline, NokiColors.dark.offlineSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(
          NokiColors.light.offline,
          NokiColors.light.offlineSurface,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(
          NokiColors.dark.chromeInk,
          NokiColors.dark.chromeSurface,
        ),
        greaterThanOrEqualTo(10.0),
      );
    });

    testWidgets(
      'Profile without Delivery profile never shows "Livraison: Une erreur est survenue."',
      (tester) async {
        final client = FakeDriverApiClient()
          ..driverContextResponse = DriverContextResponseDto.fromJson(
            _congoDriverContext(withDeliveryProfile: false),
          );
        final storage = FakeSecureSessionStorage();
        await storage.writeAccessToken('access-token');
        await storage.writeRefreshToken('refresh-token');

        await pumpWithProviders(
          tester,
          const SettingsScreen(),
          locale: const Locale('fr'),
          theme: buildNokiTheme(NokiColors.dark, Brightness.dark),
          overrides: [
            driverApiClientProvider.overrideWithValue(client),
            secureSessionStorageProvider.overrideWithValue(storage),
          ],
        );

        expect(find.text('Livraison: Non activé'), findsOneWidget);
        expect(find.textContaining('Une erreur est survenue'), findsNothing);
      },
    );

    testWidgets(
      'NokiScreenBackground renders a sober surface with no grid CustomPaint',
      (tester) async {
        await pumpWithProviders(
          tester,
          const Scaffold(
            body: NokiScreenBackground(
              showMapGrid: true,
              child: Text('Clean surface'),
            ),
          ),
          theme: buildNokiTheme(NokiColors.dark, Brightness.dark),
        );

        expect(find.text('Clean surface'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(NokiScreenBackground),
            matching: find.byType(CustomPaint),
          ),
          findsNothing,
        );
      },
    );
  });

  group('P0 MFA opaque contrast and keyboard accessibility', () {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      testWidgets(
        'MfaEnrollScreen keeps key, 6-digit field and submit button opaque and reachable with keyboard open ($brightness)',
        (tester) async {
          tester.view.physicalSize = const Size(360, 680);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          final client = FakeDriverApiClient()
            ..loginMfaChallengeResponse = AuthMfaChallengeResponseDto.fromJson(
              sampleMfaChallenge(mfaStatus: 'ENROLL'),
            )
            ..mfaEnrollStartResponse = MfaEnrollmentStartResponseDto.fromJson(
              sampleMfaEnrollmentStart(),
            );
          final container = ProviderContainer(
            overrides: [
              driverApiClientProvider.overrideWithValue(client),
              secureSessionStorageProvider.overrideWithValue(
                FakeSecureSessionStorage(),
              ),
              mapTileProvider.overrideWithValue(FakeTileProvider()),
            ],
          );
          addTearDown(container.dispose);
          container.read(authControllerProvider);
          await _settleBootstrap(tester, container);
          await container
              .read(authControllerProvider.notifier)
              .login(email: 'a@b.test', password: 'secret');

          final colors = brightness == Brightness.dark
              ? NokiColors.dark
              : NokiColors.light;

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MediaQuery(
                data: const MediaQueryData(
                  size: Size(360, 680),
                  viewInsets: EdgeInsets.only(bottom: 300),
                ),
                child: MaterialApp(
                  locale: const Locale('fr'),
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: buildNokiTheme(colors, brightness),
                  home: const MfaEnrollScreen(),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final secretText = tester.widget<SelectableText>(
            find.ancestor(
              of: find.text('JBSWY3DPEHPK3PXP'),
              matching: find.byType(SelectableText),
            ),
          );
          expect(secretText.style?.color, colors.textPrimary);
          expect(
            _contrastRatio(secretText.style!.color!, colors.surfaceSubtle),
            greaterThanOrEqualTo(4.5),
          );

          await tester.ensureVisible(find.text('Confirmer'));
          await tester.pumpAndSettle();
          expect(find.text('Confirmer'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'MfaRecoveryCodesScreen displays high-contrast recovery codes ($brightness)',
        (tester) async {
          final client = FakeDriverApiClient()
            ..loginMfaChallengeResponse = AuthMfaChallengeResponseDto.fromJson(
              sampleMfaChallenge(mfaStatus: 'ENROLL'),
            )
            ..mfaEnrollConfirmResponse = MfaEnrollConfirmResponseDto.fromJson(
              sampleMfaEnrollConfirm(),
            );
          final container = ProviderContainer(
            overrides: [
              driverApiClientProvider.overrideWithValue(client),
              secureSessionStorageProvider.overrideWithValue(
                FakeSecureSessionStorage(),
              ),
            ],
          );
          addTearDown(container.dispose);
          container.read(authControllerProvider);
          await _settleBootstrap(tester, container);
          final notifier = container.read(authControllerProvider.notifier);
          await notifier.login(email: 'a@b.test', password: 'secret');
          await notifier.confirmMfaEnrollment(code: '123456');

          final colors = brightness == Brightness.dark
              ? NokiColors.dark
              : NokiColors.light;

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                locale: const Locale('fr'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: buildNokiTheme(colors, brightness),
                home: const MfaRecoveryCodesScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final codeWidget = tester.widget<SelectableText>(
            find.ancestor(
              of: find.text('ABCD-EFGH-JKMN'),
              matching: find.byType(SelectableText),
            ),
          );
          expect(codeWidget.style?.color, colors.textPrimary);
          expect(
            _contrastRatio(codeWidget.style!.color!, colors.surfaceSubtle),
            greaterThanOrEqualTo(4.5),
          );
        },
      );
    }

    testWidgets(
      'MfaVerifyScreen works cleanly in Arabic RTL with open keyboard',
      (tester) async {
        tester.view.physicalSize = const Size(360, 680);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final client = FakeDriverApiClient()
          ..loginMfaChallengeResponse = AuthMfaChallengeResponseDto.fromJson(
            sampleMfaChallenge(mfaStatus: 'VERIFY'),
          );
        final container = ProviderContainer(
          overrides: [
            driverApiClientProvider.overrideWithValue(client),
            secureSessionStorageProvider.overrideWithValue(
              FakeSecureSessionStorage(),
            ),
          ],
        );
        addTearDown(container.dispose);
        container.read(authControllerProvider);
        await _settleBootstrap(tester, container);
        await container
            .read(authControllerProvider.notifier)
            .login(email: 'a@b.test', password: 'secret');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 680),
                viewInsets: EdgeInsets.only(bottom: 280),
              ),
              child: MaterialApp(
                locale: const Locale('ar'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: buildNokiTheme(NokiColors.dark, Brightness.dark),
                home: const MfaVerifyScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          Directionality.of(tester.element(find.byType(MfaVerifyScreen))),
          TextDirection.rtl,
        );
        await tester.ensureVisible(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('P0 Work filters (Taxi, Taxi Moto, Colis, Cargo) & History states', () {
    testWidgets(
      'WorkFeedScreen filters Taxi, Taxi Moto, Colis and Cargo in French and Arabic RTL',
      (tester) async {
        final client = FakeDriverApiClient()
          ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(
            _multiServiceWorkFeed(),
          );

        await pumpWithProviders(
          tester,
          const WorkFeedScreen(scope: _cgScope),
          locale: const Locale('fr'),
          overrides: [driverApiClientProvider.overrideWithValue(client)],
        );

        // Taxi filter
        await tester.tap(find.byKey(const Key('work-filter-taxi')));
        await tester.pumpAndSettle();
        expect(find.text('Rond-point Poto-Poto'), findsOneWidget);
        expect(find.text('Marché Total Bacongo'), findsNothing);

        // Taxi Moto filter
        await tester.tap(find.byKey(const Key('work-filter-taxiMoto')));
        await tester.pumpAndSettle();
        expect(find.text('Marché Total Bacongo'), findsOneWidget);
        expect(find.text('Rond-point Poto-Poto'), findsNothing);

        // Colis (parcel) filter includes both delivery shipments and courier items
        await tester.scrollUntilVisible(
          find.byKey(const Key('work-filter-parcel')),
          120,
          scrollable: find.descendant(
            of: find.byKey(const Key('work-feed-filter-bar')),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.tap(find.byKey(const Key('work-filter-parcel')));
        await tester.pumpAndSettle();
        expect(find.text('Avenue Amilcar Cabral, Brazzaville'), findsOneWidget);
        expect(find.text('Plateau des 15 Ans'), findsOneWidget);
        expect(find.text('Rond-point Poto-Poto'), findsNothing);

        // Cargo filter
        await tester.scrollUntilVisible(
          find.byKey(const Key('work-filter-cargo')),
          120,
          scrollable: find.descendant(
            of: find.byKey(const Key('work-feed-filter-bar')),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.tap(find.byKey(const Key('work-filter-cargo')));
        await tester.pumpAndSettle();
        expect(find.text('Zone Industrielle Mpila'), findsOneWidget);
        expect(find.text('Plateau des 15 Ans'), findsNothing);
      },
    );

    testWidgets(
      'DeliveryHistoryScreen and MobilityHistoryScreen distinguish unavailable access (404/403) from generic errors',
      (tester) async {
        final delivery404Client = FakeDriverApiClient()
          ..listOwnMissionsFailure = const AppFailure(
            AppFailureType.notFound,
            statusCode: 404,
            message: 'Driver mission profile not found',
          );

        await pumpWithProviders(
          tester,
          const DeliveryHistoryScreen(scope: _cgScope),
          locale: const Locale('fr'),
          overrides: [
            driverApiClientProvider.overrideWithValue(delivery404Client),
          ],
        );

        expect(
          find.text('Historique des livraisons indisponible'),
          findsOneWidget,
        );
        expect(find.text('Introuvable.'), findsNothing);

        final mobility404Client = FakeDriverApiClient()
          ..mobilityRideHistoryFailure = const AppFailure(
            AppFailureType.notFound,
            statusCode: 404,
          );

        await pumpWithProviders(
          tester,
          const MobilityHistoryScreen(scope: _cgScope),
          locale: const Locale('fr'),
          overrides: [
            driverApiClientProvider.overrideWithValue(mobility404Client),
          ],
        );

        expect(find.text('Historique Mobility indisponible'), findsOneWidget);
        expect(find.text('Introuvable.'), findsNothing);

        final serverErrorClient = FakeDriverApiClient()
          ..mobilityRideHistoryFailure = const AppFailure(
            AppFailureType.server,
            statusCode: 500,
          );

        await pumpWithProviders(
          tester,
          const MobilityHistoryScreen(scope: _cgScope),
          locale: const Locale('fr'),
          overrides: [
            driverApiClientProvider.overrideWithValue(serverErrorClient),
          ],
        );

        expect(find.text('Réessayer'), findsOneWidget);
      },
    );
  });
}
