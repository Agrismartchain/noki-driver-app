import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/features/delivery/delivery_work_card.dart';
import 'package:noki_driver_app/features/mobility/mobility_work_card.dart';

import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

void main() {
  testWidgets('delivery COD is presented as amount to collect, not earnings', (
    tester,
  ) async {
    final deliveryItem = DriverWorkFeedItemDto.fromJson({
      ...sampleWorkFeedDeliveryItem(),
      'amount': {'amount': '25 000', 'currencyCode': 'FCFA'},
    });

    await pumpWithProviders(
      tester,
      Scaffold(
        body: DeliveryWorkCard(item: deliveryItem, onTap: () {}),
      ),
    );

    expect(find.text('AMOUNT TO COLLECT'), findsOneWidget);
    expect(find.text('25 000 FCFA'), findsOneWidget);
    expect(find.text('Estimated fare'), findsNothing);
  });

  testWidgets('mobility fare context stays distinct from COD collection', (
    tester,
  ) async {
    final rideItem = DriverWorkFeedItemDto.fromJson({
      ...sampleWorkFeedRideItem(),
      'amount': {'amount': '1 200', 'currencyCode': 'FCFA'},
    });

    await pumpWithProviders(
      tester,
      Scaffold(
        body: MobilityWorkCard(item: rideItem, onTap: () {}),
      ),
    );

    expect(find.text('ESTIMATED FARE'), findsOneWidget);
    expect(find.text('1 200 FCFA'), findsOneWidget);
    expect(find.text('Amount to collect'), findsNothing);
  });
}
