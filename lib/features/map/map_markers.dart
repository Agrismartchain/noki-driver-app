import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import 'map_point.dart';

/// The three marker kinds the mandate requires at minimum (§14): driver,
/// pickup, drop-off - visually distinct but flat/bordered like the rest of
/// NOKI (no gradients, no shadows). Left/right never encodes meaning, so
/// these render identically under RTL (mandate §14/§51).
Marker driverMarker(MapPoint point, NokiColorScheme colors) {
  return Marker(
    point: LatLng(point.latitude, point.longitude),
    width: 40,
    height: 40,
    child: Semantics(
      label: 'Driver marker',
      child: Container(
        key: const Key('noki-map-marker-driver'),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.actionPrimary,
          border: Border.all(color: colors.chromeSurface, width: 2),
          boxShadow: [
            BoxShadow(
              color: colors.shadowColor.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.actionPrimaryInk,
            ),
          ),
        ),
      ),
    ),
  );
}

Marker pickupMarker(MapPoint point, NokiColorScheme colors) {
  return Marker(
    point: LatLng(point.latitude, point.longitude),
    width: 40,
    height: 52,
    alignment: Alignment.topCenter,
    child: Semantics(
      label: 'Pickup marker',
      child: SizedBox(
        key: const Key('noki-map-marker-pickup'),
        width: 40,
        height: 52,
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                border: Border.all(color: colors.actionPrimary, width: 3),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.actionPrimaryInk,
                  ),
                ),
              ),
            ),
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: colors.actionPrimaryInk,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Marker dropoffMarker(MapPoint point, NokiColorScheme colors) {
  return Marker(
    point: LatLng(point.latitude, point.longitude),
    width: 40,
    height: 52,
    alignment: Alignment.topCenter,
    child: Semantics(
      label: 'Destination marker',
      child: SizedBox(
        key: const Key('noki-map-marker-dropoff'),
        width: 40,
        height: 52,
        child: Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colors.chromeSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.surface, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.textInverse,
                  ),
                ),
              ),
            ),
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: colors.chromeSurface,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
