import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/work_feed/work_feed_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  testWidgets('TAXI offer card opens detail from the work-feed item even when the offers list is empty', (tester) async {
    await _pumpAndOpenOffer(
      tester,
      sampleWorkFeedOfferItem(),
      expectedHeading: 'Taxi',
      expectedFare: '85.00 MAD',
    );
  });

  testWidgets('TAXI_MOTO offer card opens detail from the work-feed item even when the offers list is empty', (tester) async {
    final taxiMotoItem = {
      ...sampleWorkFeedOfferItem(),
      'workItemId': 'work-4',
      'serviceType': 'TAXI_MOTO',
      'amount': {'amount': '112.00', 'currencyCode': 'MAD'},
      'underlyingResource': {'resourceType': 'MobilityRideOffer', 'resourceId': 'offer-2'},
    };

    await _pumpAndOpenOffer(
      tester,
      taxiMotoItem,
      expectedHeading: 'Taxi Moto',
      expectedFare: '112.00 MAD',
    );
  });
}

Future<void> _pumpAndOpenOffer(
  WidgetTester tester,
  Map<String, dynamic> workFeedOfferItem, {
  required String expectedHeading,
  required String expectedFare,
}) async {
  final client = FakeDriverApiClient()
    ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson({
      'items': [workFeedOfferItem],
      'total': 1,
      'page': 1,
      'pageSize': 25,
    })
    ..mobilityOffersResponse = DriverMobilityOfferListResponseDto.fromJson({
      'items': [],
      'total': 0,
      'page': 1,
      'pageSize': 25,
    });

  final container = ProviderContainer(overrides: [
    driverApiClientProvider.overrideWithValue(client),
  ]);
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildNokiTheme(NokiColors.light, Brightness.light),
        home: const WorkFeedScreen(scope: _scope),
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('This offer is no longer available'), findsNothing);

  await tester.tap(find.text('Gare Casa-Voyageurs'));
  await tester.pumpAndSettle();

  expect(find.text('Ride offer'), findsOneWidget);
  expect(find.text('This offer is no longer available'), findsNothing);
  expect(find.text(expectedHeading), findsOneWidget);
  expect(find.text('Gare Casa-Voyageurs'), findsOneWidget);
  expect(find.text('Aéroport Mohammed V'), findsOneWidget);
  expect(find.text(expectedFare), findsOneWidget);
  expect(find.widgetWithText(ElevatedButton, 'Accept offer'), findsOneWidget);
  expect(client.lastAcceptedOfferId, isNull);
}
