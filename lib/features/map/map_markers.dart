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
    width: 26,
    height: 26,
    child: Container(
      decoration: BoxDecoration(
        color: colors.actionPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: colors.surface, width: 3),
      ),
    ),
  );
}

Marker pickupMarker(MapPoint point, NokiColorScheme colors) {
  return Marker(
    point: LatLng(point.latitude, point.longitude),
    width: 34,
    height: 34,
    alignment: Alignment.topCenter,
    child: Icon(Icons.trip_origin, color: colors.textSecondary, size: 30),
  );
}

Marker dropoffMarker(MapPoint point, NokiColorScheme colors) {
  return Marker(
    point: LatLng(point.latitude, point.longitude),
    width: 34,
    height: 34,
    alignment: Alignment.topCenter,
    child: Icon(Icons.place, color: colors.actionDanger, size: 32),
  );
}
