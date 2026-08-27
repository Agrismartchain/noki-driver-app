import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/mobility/mobility_offer_detail_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  testWidgets(
    'fromWorkFeedItem renders the canonical pickup, dropoff, and fare data directly from the feed item',
    (tester) async {
      final item = DriverWorkFeedItemDto.fromJson(sampleWorkFeedOfferItem());

      await pumpWithProviders(
        tester,
        MobilityOfferDetailScreen.fromWorkFeedItem(item: item, scope: _scope),
      );

      expect(find.text('Gare Casa-Voyageurs'), findsOneWidget);
      expect(find.text('Aéroport Mohammed V'), findsOneWidget);
      expect(find.text('85.00 MAD'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Accept offer'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'accepting an offer keeps the canonical flow and pushes the active ride screen',
    (tester) async {
      final client = FakeDriverApiClient()
        ..acceptMobilityOfferResponse = MobilityRideDetailDto.fromJson(
          sampleMobilityRide(),
        )
        ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(
          sampleMobilityRide(),
        );
      final item = DriverWorkFeedItemDto.fromJson(sampleWorkFeedOfferItem());

      await pumpWithProviders(
        tester,
        MobilityOfferDetailScreen.fromWorkFeedItem(item: item, scope: _scope),
        overrides: [driverApiClientProvider.overrideWithValue(client)],
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Accept offer'));
      await tester.pumpAndSettle();

      expect(client.lastAcceptedOfferId, 'offer-1');
      expect(find.text('Ride'), findsOneWidget);
    },
  );

  testWidgets(
    'a CARGO work-feed offer renders as Cargo, not Unknown, with its real pickup/dropoff/fare',
    (tester) async {
      final item = DriverWorkFeedItemDto.fromJson(
        sampleWorkFeedCargoOfferItem(),
      );

      await pumpWithProviders(
        tester,
        MobilityOfferDetailScreen.fromWorkFeedItem(item: item, scope: _scope),
      );

      expect(find.text('Cargo'), findsOneWidget);
      expect(find.text('Unknown'), findsNothing);
      expect(find.text('Zone Industrielle Ain Sebaa'), findsOneWidget);
      expect(find.text('Route de Rabat'), findsOneWidget);
      expect(find.text('350.00 MAD'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Accept offer'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'accepting a CARGO offer works through the same canonical accept action as any other offer',
    (tester) async {
      final client = FakeDriverApiClient()
        ..acceptMobilityOfferResponse = MobilityRideDetailDto.fromJson(
          sampleMobilityRide(serviceType: 'CARGO'),
        )
        ..mobilityRideByIdResponse = MobilityRideDetailDto.fromJson(
          sampleMobilityRide(serviceType: 'CARGO'),
        );
      final item = DriverWorkFeedItemDto.fromJson(
        sampleWorkFeedCargoOfferItem(),
      );

      await pumpWithProviders(
        tester,
        MobilityOfferDetailScreen.fromWorkFeedItem(item: item, scope: _scope),
        overrides: [driverApiClientProvider.overrideWithValue(client)],
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Accept offer'));
      await tester.pumpAndSettle();

      expect(client.lastAcceptedOfferId, 'offer-cargo-1');
      expect(find.text('Cargo'), findsOneWidget);
    },
  );
}
