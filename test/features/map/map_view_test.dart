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

  testWidgets(
    'draws a route polyline below the marker layer when real backend geometry is supplied',
    (tester) async {
      await pumpWithProviders(
        tester,
        Scaffold(
          body: NokiMapView(
            tileProvider: FakeTileProvider(),
            driverPosition: MapPoint(5.34, -4.02),
            pickup: MapPoint(5.35, -4.01),
            dropoff: MapPoint(5.36, -4.00),
            routeGeometry: const [
              MapPoint(5.34, -4.02),
              MapPoint(5.35, -4.015),
              MapPoint(5.36, -4.00),
            ],
          ),
        ),
      );

      expect(find.byType(PolylineLayer), findsOneWidget);
      expect(find.byKey(const Key('noki-map-marker-driver')), findsOneWidget);

      final flutterMap = tester.widget<FlutterMap>(find.byType(FlutterMap));
      final children = flutterMap.children;
      final polylineIndex = children.indexWhere((w) => w is PolylineLayer);
      final markerIndex = children.indexWhere((w) => w is MarkerLayer);
      expect(polylineIndex, greaterThanOrEqualTo(0));
      expect(markerIndex, greaterThanOrEqualTo(0));
      expect(
        polylineIndex,
        lessThan(markerIndex),
        reason: 'the route must never occlude the markers drawn on top of it',
      );
    },
  );

  testWidgets('draws no polyline when routeGeometry is empty, same as null', (
    tester,
  ) async {
    await pumpWithProviders(
      tester,
      Scaffold(
        body: NokiMapView(
          tileProvider: FakeTileProvider(),
          driverPosition: MapPoint(5.34, -4.02),
          routeGeometry: const [],
        ),
      ),
    );

    expect(find.byType(PolylineLayer), findsNothing);
  });

  testWidgets('shows an OpenStreetMap attribution over the tiles', (
    tester,
  ) async {
    await pumpWithProviders(
      tester,
      Scaffold(
        body: NokiMapView(
          tileProvider: FakeTileProvider(),
          driverPosition: MapPoint(5.34, -4.02),
        ),
      ),
    );

    expect(find.byType(SimpleAttributionWidget), findsOneWidget);
    expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
  });
}
