import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/work_feed/work_feed_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/test_harness.dart';

// Regression coverage mirroring vehicles_responsive_test.dart: a long
// customer name / long address / long COD amount must never overflow the
// Delivery or Ride cards, at the narrowest width this app targets, in
// French and Arabic RTL, in dark mode.
const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

Map<String, dynamic> _longFeedJson() => {
      'items': [
        {
          'workItemId': 'work-long-1',
          'workType': 'DELIVERY',
          'serviceType': 'DELIVERY',
          'sourceDomain': 'COMMERCE',
          'status': 'OUT_FOR_DELIVERY',
          'createdAt': '2026-08-18T09:00:00.000Z',
          'updatedAt': '2026-08-18T09:05:00.000Z',
          'pickup': {'label': 'Entrepôt Central de Distribution Régionale Casablanca-Settat', 'addressLine1': null, 'latitude': null, 'longitude': null},
          'dropoff': {
            'label': null,
            'addressLine1': 'Résidence Al Andalous Immeuble 12 Appartement 34, Boulevard Mohammed VI, Quartier Administratif',
            'latitude': null,
            'longitude': null,
          },
          'amount': {'amount': '123456.99', 'currencyCode': 'MAD'},
          'actions': ['VIEW_MISSION'],
          'underlyingResource': {'resourceType': 'DeliveryShipment', 'resourceId': 'shipment-long-1'},
        },
        {
          'workItemId': 'work-long-2',
          'workType': 'RIDE',
          'serviceType': 'TAXI_MOTO',
          'sourceDomain': 'MOBILITY_OFFER',
          'status': 'OFFERED',
          'createdAt': '2026-08-18T09:00:00.000Z',
          'updatedAt': '2026-08-18T09:00:00.000Z',
          'pickup': {'label': 'Aéroport International Mohammed V Terminal 1 Zone Arrivées', 'addressLine1': null, 'latitude': 33.37, 'longitude': -7.59},
          'dropoff': {'label': 'Centre-ville Twin Center Tour Nord', 'addressLine1': null, 'latitude': 33.59, 'longitude': -7.63},
          'amount': {'amount': '250.00', 'currencyCode': 'MAD'},
          'actions': ['ACCEPT_OFFER'],
          'underlyingResource': {'resourceType': 'MobilityRideOffer', 'resourceId': 'offer-long-1'},
        },
      ],
      'total': 2,
      'page': 1,
      'pageSize': 25,
    };

Future<void> _pumpAtWidth(WidgetTester tester, {required double width, Locale locale = const Locale('fr')}) async {
  tester.view.physicalSize = Size(width, 900) * tester.view.devicePixelRatio;
  addTearDown(tester.view.reset);

  final client = FakeDriverApiClient()..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(_longFeedJson());

  await pumpWithProviders(
    tester,
    const WorkFeedScreen(scope: _scope),
    overrides: [driverApiClientProvider.overrideWithValue(client)],
    locale: locale,
  );
}

void main() {
  for (final width in [320.0, 360.0, 390.0, 430.0]) {
    testWidgets('no overflow at ${width}dp in French', (tester) async {
      await _pumpAtWidth(tester, width: width);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('no overflow at 320dp in Arabic RTL', (tester) async {
    await _pumpAtWidth(tester, width: 320, locale: const Locale('ar'));
    expect(tester.takeException(), isNull);
  });
}
