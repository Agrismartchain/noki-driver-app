import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';
import 'map_chrome.dart';
import 'map_markers.dart';
import 'map_point.dart';

/// The one place `flutter_map`'s types are used directly (mandate §5).
/// Business screens hand in plain [MapPoint]s; this widget owns tiles,
/// markers, camera fit and the recenter action.
///
/// No route polyline is drawn: the backend provides no routing geometry, and
/// mandate §16 forbids labelling a straight line as a "route" - markers only.
class NokiMapView extends StatefulWidget {
  const NokiMapView({
    super.key,
    this.driverPosition,
    this.pickup,
    this.dropoff,
    this.tileProvider,
  });

  final MapPoint? driverPosition;
  final MapPoint? pickup;
  final MapPoint? dropoff;

  /// Overridable only so widget tests can substitute a tile source that
  /// doesn't hit the real network (see `test/fixtures/fake_tile_provider.dart`)
  /// - defaults to the real OSM `NetworkTileProvider` in the app.
  final TileProvider? tileProvider;

  @override
  State<NokiMapView> createState() => _NokiMapViewState();
}

class _NokiMapViewState extends State<NokiMapView> {
  final _controller = MapController();
  bool _fitted = false;

  List<MapPoint> get _points => [
    if (widget.driverPosition != null) widget.driverPosition!,
    if (widget.pickup != null) widget.pickup!,
    if (widget.dropoff != null) widget.dropoff!,
  ];

  @override
  void initState() {
    super.initState();
    if (_points.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
    }
  }

  @override
  void didUpdateWidget(covariant NokiMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fit once when the points first become available; afterwards the
    // driver's own pans/zooms are respected (mandate §15) until they tap
    // recenter.
    if (!_fitted && _points.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
    }
  }

  void _fit() {
    final points = _points;
    if (points.isEmpty || !mounted) return;
    _fitted = true;
    if (points.length == 1) {
      _controller.move(
        LatLng(points.first.latitude, points.first.longitude),
        15,
      );
      return;
    }
    _controller.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(
          points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        ),
        padding: const EdgeInsets.all(56),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final points = _points;
    final initialCenter = points.isNotEmpty
        ? LatLng(points.first.latitude, points.first.longitude)
        : const LatLng(0, 0);

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: points.isEmpty ? 2 : 15,
          ),
          children: [
            ColorFiltered(
              colorFilter: isDark ? _darkMapFilter : _lightMapFilter,
              child: _tileLayer(),
            ),
            MarkerLayer(
              markers: [
                if (widget.pickup != null) pickupMarker(widget.pickup!, colors),
                if (widget.dropoff != null)
                  dropoffMarker(widget.dropoff!, colors),
                if (widget.driverPosition != null)
                  driverMarker(widget.driverPosition!, colors),
              ],
            ),
          ],
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.chromeSurface.withValues(
                      alpha: isDark ? 0.24 : 0.08,
                    ),
                    Colors.transparent,
                    colors.background.withValues(alpha: 0.06),
                    colors.background.withValues(alpha: 0.24),
                  ],
                  stops: const [0, 0.18, 0.72, 1],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 20,
          child: NokiMapControlButton(
            icon: Icons.my_location_rounded,
            tooltip: 'Recenter map',
            onPressed: () {
              _fitted = false;
              _fit();
            },
          ),
        ),
      ],
    );
  }

  Widget _tileLayer() => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.noki.driver_app',
    maxZoom: 19,
    tileProvider: widget.tileProvider,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

const _lightMapFilter = ColorFilter.matrix(<double>[
  0.5,
  0.5,
  0.5,
  0,
  12,
  0.5,
  0.5,
  0.5,
  0,
  12,
  0.5,
  0.5,
  0.5,
  0,
  12,
  0,
  0,
  0,
  1,
  0,
]);

const _darkMapFilter = ColorFilter.matrix(<double>[
  0.36,
  0.36,
  0.36,
  0,
  18,
  0.36,
  0.36,
  0.36,
  0,
  18,
  0.36,
  0.36,
  0.36,
  0,
  18,
  0,
  0,
  0,
  1,
  0,
]);
