import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/features/map/map_point.dart';
import 'package:noki_driver_app/features/map/map_view.dart';

import '../../fixtures/fake_tile_provider.dart';
import '../../fixtures/test_harness.dart';

void main() {
  testWidgets(
    'driver, pickup, and destination markers remain semantically distinct without drawing a fake route',
    (tester) async {
      await pumpWithProviders(
        tester,
        Scaffold(
          body: NokiMapView(
            tileProvider: FakeTileProvider(),
            driverPosition: MapPoint(5.34, -4.02),
            pickup: MapPoint(5.35, -4.01),
            dropoff: MapPoint(5.36, -4.00),
          ),
        ),
      );

      expect(find.byKey(const Key('noki-map-marker-driver')), findsOneWidget);
      expect(find.byKey(const Key('noki-map-marker-pickup')), findsOneWidget);
      expect(find.byKey(const Key('noki-map-marker-dropoff')), findsOneWidget);
      expect(find.byType(PolylineLayer), findsNothing);
    },
  );
}
