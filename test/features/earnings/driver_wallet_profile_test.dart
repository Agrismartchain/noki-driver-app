import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:noki_driver_app/app/home_shell.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/finance/driver_finance_models.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/api/profile/driver_avatar_models.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/location/location_repository.dart';
import 'package:noki_driver_app/core/storage/storage_providers.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/core/theme/theme_controller.dart';
import 'package:noki_driver_app/features/auth/auth_providers.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/earnings/earnings_screen.dart';
import 'package:noki_driver_app/features/map/map_view.dart';
import 'package:noki_driver_app/features/profile/driver_avatar_picker.dart';
import 'package:noki_driver_app/features/settings/settings_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_location_repository.dart';
import '../../fixtures/fake_session_storage.dart';
import '../../fixtures/fake_tile_provider.dart';
import '../../fixtures/test_harness.dart';

// Minimal valid 1x1 transparent PNG bytes for Image.memory preview tests.
final _validPngBytes = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _FakeAvatarPicker implements DriverAvatarPicker {
  PickedAvatarImage? nextImage;
  int callCount = 0;

  @override
  Future<PickedAvatarImage?> pick(DriverAvatarSource source) async {
    callCount++;
    return nextImage;
  }
}

const _scope = DriverScope(organizationId: 'org-cg-1', countryCode: 'CG');

DriverContextResponseDto _congoDriverContext() {
  return const DriverContextResponseDto(
    actorId: 'actor-cg-1',
    displayName: 'Jean-Paul Mabiala',
    email: 'jp.mabiala@noki.cg',
    effectivePermissionCodes: [
      'driver.profile.read_own',
      'driver.profile.update_own',
      'driver.work.read_own',
      'driver.finance.summary.read_own',
      'mobility.ride.read_own',
      'delivery.mission.read_own',
    ],
    capabilities: [
      'driver.profile.read_own',
      'driver.profile.update_own',
      'driver.work.read_own',
      'driver.finance.summary.read_own',
      'mobility.ride.read_own',
      'delivery.mission.read_own',
      'extra.perm.7',
      'extra.perm.8',
      'extra.perm.9',
      'extra.perm.10',
      'extra.perm.11',
      'extra.perm.12',
      'extra.perm.13',
      'extra.perm.14',
      'extra.perm.15',
      'extra.perm.16',
      'extra.perm.17',
      'extra.perm.18',
      'extra.perm.19',
      'extra.perm.20',
      'extra.perm.21',
    ],
    profiles: [
      DriverContextProfileDto(
        organizationId: 'org-cg-1',
        organizationName: 'NOKI Congo',
        countryId: 'country-cg',
        countryCode: 'CG',
        deliveryProfileId: 'del-1',
        deliveryStatus: DriverContextProfileDtoDeliveryStatus.active,
        mobilityProfileId: 'mob-1',
        mobilityOnboardingStatus:
            DriverContextProfileDtoMobilityOnboardingStatus.approved,
        mobilityOperationalStatus:
            DriverContextProfileDtoMobilityOperationalStatus.active,
        mobilityAvailabilityStatus:
            DriverContextProfileDtoMobilityAvailabilityStatus.available,
        serviceTypes: [
          DriverContextProfileDtoServiceTypes.taxi,
          DriverContextProfileDtoServiceTypes.taxiMoto,
          DriverContextProfileDtoServiceTypes.courier,
          DriverContextProfileDtoServiceTypes.cargo,
        ],
      ),
    ],
  );
}

FakeSecureSessionStorage _authenticatedStorage() {
  final storage = FakeSecureSessionStorage();
  storage.writeAccessToken('access-tok-1');
  storage.writeRefreshToken('refresh-tok-1');
  return storage;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Gains & Portefeuille (XAF, COD separation, Payouts)', () {
    testWidgets(
      'displays available, pending, paid, onHold in XAF, separates COD, and submits payout request',
      (tester) async {
        final api = FakeDriverApiClient()
          ..driverContextResponse = _congoDriverContext()
          ..driverFinanceSummaryResponse = const DriverFinanceSummaryDto(
            driverActorId: 'actor-cg-1',
            organizationId: 'org-cg-1',
            countryCode: 'CG',
            currencyCode: 'XAF',
            availableAmount: '30200',
            pendingPayoutAmount: '8500',
            paidAmount: '45000',
            onHoldAmount: '1500',
            grossEarnedAmount: '85200',
            receivableCommissionAmount: '1500',
            paymentMethodStatus: 'ACTIVE',
            defaultPaymentMethodId: 'pm-1',
            defaultPaymentMethodType: 'MOBILE_MONEY',
            defaultPaymentMethodMasked: '+242 05***88',
            canRequestPayout: true,
            missingRemunerationRuleServices: [],
            codSummary: DriverCodSummaryDto(
              currencyCode: 'XAF',
              toRemitAmount: '12000',
              remittedAmount: '5000',
              reconciledAmount: '20000',
              toRemitCount: 1,
              totalDeclaredCount: 3,
            ),
            generatedAt: '2026-11-27T11:00:00Z',
          )
          ..driverPayoutEligibilityResponse = const DriverPayoutEligibilityDto(
            eligible: true,
            currencyCode: 'XAF',
            availableAmount: '30200',
            defaultPaymentMethodId: 'pm-1',
            defaultPaymentMethodType: 'MOBILE_MONEY',
            defaultPaymentMethodMasked: '+242 05***88',
            eligibleObligationIds: ['ob-1', 'ob-2'],
            blockers: [],
          )
          ..driverFinanceEarningsResponse = const [
            DriverEarningItemDto(
              id: 'ob-1',
              sourceDomain: 'MOBILITY_TAXI',
              serviceCode: 'TAXI',
              sourceReferenceType: 'MOBILITY_RIDE',
              sourceReferenceId: 'ride-abcdef1234',
              direction: 'PAYABLE',
              nature: 'SERVICE_FEE',
              status: 'OPEN',
              currencyCode: 'XAF',
              originalAmount: '8500',
              allocatedAmount: '0',
              settledAmount: '0',
              remainingAmount: '8500',
              createdAt: '2026-11-27T09:00:00Z',
            ),
          ]
          ..driverPayoutsResponse = const [
            DriverPayoutItemDto(
              id: 'payout-pending-1',
              code: 'P2-CG001',
              status: 'PENDING_FIRST_APPROVAL',
              currencyCode: 'XAF',
              totalAmount: '8500',
              destinationMasked: '+242 05***88',
              paymentMethodType: 'MOBILE_MONEY',
              lineCount: 1,
              createdAt: '2026-11-27T08:00:00Z',
            ),
          ]
          ..driverFinanceCodResponse = const [
            DriverCodCollectionItemDto(
              id: 'cod-1',
              orderId: 'order-1234567890',
              deliveryShipmentId: 'ship-1',
              status: 'DECLARED',
              currencyCode: 'XAF',
              expectedAmount: '12000',
              collectedAmount: '12000',
              declaredAt: '2026-11-27T07:30:00Z',
            ),
          ];

        await pumpWithProviders(
          tester,
          const EarningsScreen(scope: _scope),
          locale: const Locale('fr'),
          overrides: [
            driverApiClientProvider.overrideWithValue(api),
            secureSessionStorageProvider.overrideWithValue(
              _authenticatedStorage(),
            ),
          ],
        );

        expect(find.text('30200 XAF'), findsOneWidget);
        expect(find.text('8500 XAF'), findsWidgets);
        expect(find.text('45000 XAF'), findsOneWidget);
        expect(find.text('1500 XAF'), findsOneWidget);
        // COD callout is displayed separately from driver earnings
        expect(find.byKey(const Key('earnings-cod-callout')), findsOneWidget);
        expect(find.text('12000 XAF'), findsWidgets);

        // Open Request Payout sheet & confirm
        await tester.tap(find.byKey(const Key('earnings-request-payout-button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('payout-confirm-button')), findsOneWidget);
        await tester.tap(find.byKey(const Key('payout-confirm-button')));
        await tester.pumpAndSettle();

        expect(api.requestDriverPayoutCallCount, 1);
        expect(api.lastRequestDriverPayoutAmount, '30200');
        expect(api.lastRequestDriverPayoutIdempotencyKey, isNotEmpty);
      },
    );

    testWidgets(
      'distinguishes real 0 XAF balance from 404 unavailable backend and 500 technical error',
      (tester) async {
        // Case 1: Real 0 XAF balance
        final zeroApi = FakeDriverApiClient()
          ..driverContextResponse = _congoDriverContext();

        await pumpWithProviders(
          tester,
          const EarningsScreen(scope: _scope),
          locale: const Locale('fr'),
          overrides: [
            driverApiClientProvider.overrideWithValue(zeroApi),
            secureSessionStorageProvider.overrideWithValue(
              _authenticatedStorage(),
            ),
          ],
        );

        expect(find.byKey(const Key('earnings-available-callout')), findsOneWidget);
        expect(find.text('0 XAF'), findsWidgets);
        expect(find.text('Votre solde vérifié est actuellement à 0.'), findsOneWidget);

        // Case 2: 404 Not Found -> Unavailable (NOT 0 XAF!)
        final unavailableApi = FakeDriverApiClient()
          ..driverContextResponse = _congoDriverContext()
          ..driverFinanceSummaryFailure = const AppFailure(
            AppFailureType.notFound,
            statusCode: 404,
          );

        await pumpWithProviders(
          tester,
          const EarningsScreen(scope: _scope),
          locale: const Locale('fr'),
          overrides: [
            driverApiClientProvider.overrideWithValue(unavailableApi),
            secureSessionStorageProvider.overrideWithValue(
              _authenticatedStorage(),
            ),
          ],
        );

        expect(find.byKey(const Key('earnings-unavailable-view')), findsOneWidget);
        expect(find.text('Portefeuille indisponible'), findsOneWidget);
        expect(find.text('0 XAF'), findsNothing);

        // Case 3: 500 Server Error -> ErrorView with Retry
        final errorApi = FakeDriverApiClient()
          ..driverContextResponse = _congoDriverContext()
          ..driverFinanceSummaryFailure = const AppFailure(
            AppFailureType.server,
            statusCode: 500,
          );

        await pumpWithProviders(
          tester,
          const EarningsScreen(scope: _scope),
          locale: const Locale('fr'),
          overrides: [
            driverApiClientProvider.overrideWithValue(errorApi),
            secureSessionStorageProvider.overrideWithValue(
              _authenticatedStorage(),
            ),
          ],
        );

        expect(find.text('Réessayer'), findsOneWidget);
      },
    );

    for (final locale in const [Locale('fr'), Locale('en'), Locale('ar')]) {
      testWidgets(
        'HomeShell displays 4 navigation tabs cleanly in ${locale.languageCode.toUpperCase()}',
        (tester) async {
          final api = FakeDriverApiClient()
            ..driverContextResponse = _congoDriverContext()
            ..workFeedResponse = const DriverWorkFeedListResponseDto(
              items: [],
              page: 1,
              pageSize: 25,
              total: 0,
            );
          final location = FakeLocationRepository();

          await pumpWithProviders(
            tester,
            const HomeShell(),
            locale: locale,
            overrides: [
              driverApiClientProvider.overrideWithValue(api),
              secureSessionStorageProvider.overrideWithValue(
                _authenticatedStorage(),
              ),
              locationRepositoryProvider.overrideWithValue(location),
            ],
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('Profil — Apparence, Services autorisés (sans 1/21) et Avatar', () {
    testWidgets(
      'removes numeric badges 1 and 21, shows named authorized services, and places Appearance at top of Settings',
      (tester) async {
        final api = FakeDriverApiClient()
          ..driverContextResponse = _congoDriverContext();

        await pumpWithProviders(
          tester,
          const SettingsScreen(),
          locale: const Locale('fr'),
          overrides: [
            driverApiClientProvider.overrideWithValue(api),
            secureSessionStorageProvider.overrideWithValue(
              _authenticatedStorage(),
            ),
          ],
        );

        final identityCard = find.byKey(const Key('profile-identity-card'));
        expect(identityCard, findsOneWidget);

        // Numeric badges "1" and "21" must NOT exist on the identity card!
        expect(
          find.descendant(of: identityCard, matching: find.text('1')),
          findsNothing,
        );
        expect(
          find.descendant(of: identityCard, matching: find.text('21')),
          findsNothing,
        );
        // Raw permission strings must NEVER be displayed!
        expect(find.text('driver.profile.read_own'), findsNothing);
        expect(find.text('driver.work.read_own'), findsNothing);

        // Authorized services ARE displayed by name!
        final servicesWrap = find.byKey(
          const Key('profile-authorized-services-wrap'),
        );
        expect(
          find.descendant(of: servicesWrap, matching: find.text('Livraison')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: servicesWrap, matching: find.text('Taxi')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: servicesWrap, matching: find.text('Taxi Moto')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: servicesWrap, matching: find.text('Coursier')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: servicesWrap, matching: find.text('Cargo')),
          findsOneWidget,
        );

        // Appearance selector is immediately visible right below Identity card!
        final identityRect = tester.getRect(identityCard);
        final settingsRect = tester.getRect(
          find.byKey(const Key('profile-settings-card')),
        );
        expect(settingsRect.top, greaterThanOrEqualTo(identityRect.bottom));
        expect(
          find.byKey(const Key('profile-appearance-selector')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'switching Appearance applies theme immediately and persists across restart',
      (tester) async {
        final api = FakeDriverApiClient()
          ..driverContextResponse = _congoDriverContext();

        await pumpWithProviders(
          tester,
          const SettingsScreen(),
          locale: const Locale('fr'),
          overrides: [
            driverApiClientProvider.overrideWithValue(api),
            secureSessionStorageProvider.overrideWithValue(
              _authenticatedStorage(),
            ),
          ],
        );

        // Tap Dark mode inside Profil -> Réglages -> Apparence
        await tester.tap(find.text('Sombre'));
        await tester.pumpAndSettle();

        // Verify persistence in SharedPreferences across a fresh ProviderContainer (restart)
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final controller = container.read(themeModeProvider.notifier);
        await controller.ready;
        expect(container.read(themeModeProvider), ThemeMode.dark);

        // Also test switching back to Light
        await controller.setThemeMode(ThemeMode.light);
        final container2 = ProviderContainer();
        addTearDown(container2.dispose);
        await container2.read(themeModeProvider.notifier).ready;
        expect(container2.read(themeModeProvider), ThemeMode.light);
      },
    );

    testWidgets(
      'clickable avatar supports choose -> preview -> save -> remove and persists across re-login',
      (tester) async {
        final api = FakeDriverApiClient()
          ..driverContextResponse = _congoDriverContext()
          ..loginResponse = const AuthTokensResponseDto(
            tokenType: 'Bearer',
            accessToken: 'tok-fresh',
            refreshToken: 'ref-fresh',
            accessTokenExpiresIn: 900,
            refreshTokenExpiresIn: 2592000,
          );
        final picker = _FakeAvatarPicker()
          ..nextImage = PickedAvatarImage(
            bytes: _validPngBytes,
            contentType: 'image/png',
            filename: 'driver.png',
          );

        final container = ProviderContainer(
          overrides: [
            mapTileProvider.overrideWithValue(FakeTileProvider()),
            driverApiClientProvider.overrideWithValue(api),
            secureSessionStorageProvider.overrideWithValue(
              _authenticatedStorage(),
            ),
            driverAvatarPickerProvider.overrideWithValue(picker),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              locale: const Locale('fr'),
              theme: buildNokiTheme(NokiColors.light, Brightness.light),
              darkTheme: buildNokiTheme(NokiColors.dark, Brightness.dark),
              supportedLocales: const [
                Locale('fr'),
                Locale('en'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Tap avatar -> opens sheet
        await tester.tap(find.byKey(const Key('profile-avatar-button')));
        await tester.pumpAndSettle();

        // 2. Choose from gallery -> preview appears
        await tester.tap(find.byKey(const Key('avatar-pick-gallery-button')));
        await tester.pumpAndSettle();
        expect(picker.callCount, 1);
        expect(
          find.byKey(const Key('avatar-preview-memory-image')),
          findsOneWidget,
        );

        // 3. Save -> runs 3-step NOKI media upload and updates AuthState.avatarUrl
        await tester.tap(find.byKey(const Key('avatar-save-button')));
        await tester.pumpAndSettle();
        expect(api.uploadAvatarBytesCallCount, 1);
        expect(api.completeAvatarUploadCallCount, 1);
        expect(
          container.read(authControllerProvider).avatarUrl,
          'https://cdn.noki-services.com/avatars/driver-1.png',
        );

        // 4. Logout & re-login -> persisted avatarUrl returns from /v1/driver/context!
        await container.read(authControllerProvider.notifier).logout();
        expect(container.read(authControllerProvider).avatarUrl, isNull);
        await container
            .read(authControllerProvider.notifier)
            .login(email: 'jp.mabiala@noki.cg', password: 'secret');
        expect(
          container.read(authControllerProvider).avatarUrl,
          'https://cdn.noki-services.com/avatars/driver-1.png',
        );

        // 5. Re-open avatar sheet -> Remove photo clears avatarUrl
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('profile-avatar-button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('avatar-remove-button')));
        await tester.pumpAndSettle();
        expect(api.removeAvatarCallCount, 1);
        expect(container.read(authControllerProvider).avatarUrl, isNull);
      },
    );
  });
}
