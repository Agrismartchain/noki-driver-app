import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import 'map_chrome.dart';
import 'map_markers.dart';
import 'map_point.dart';

/// Optional tile provider override used by widget tests so embedded maps
/// (such as the Home overview map) don't perform real network fetches.
/// Production leaves this `null`, which uses `flutter_map`'s default
/// OpenStreetMap `NetworkTileProvider`.
final mapTileProvider = Provider<TileProvider?>((ref) => null);

/// The one place `flutter_map`'s types are used directly (mandate §5).
/// Business screens hand in plain [MapPoint]s; this widget owns tiles,
/// markers, camera fit/follow and the recenter action.
///
/// A route polyline is drawn only when [routeGeometry] carries real backend
/// geometry (never a straight origin->destination fallback - mandate §16):
/// when it's null or empty, nothing is drawn, exactly as before real routing
/// existed.
class NokiMapView extends StatefulWidget {
  const NokiMapView({
    super.key,
    this.driverPosition,
    this.pickup,
    this.dropoff,
    this.routeGeometry,
    this.tileProvider,
    this.fallbackCenter,
    this.fallbackZoom = 12,
    this.interactive = true,
    this.showRecenterButton = true,
  });

  final MapPoint? driverPosition;
  final MapPoint? pickup;
  final MapPoint? dropoff;

  /// Real routing geometry from the backend, already ordered start->end.
  /// Null/empty means "no route to draw" - never a fabricated straight line.
  final List<MapPoint>? routeGeometry;

  /// Overridable only so widget tests can substitute a tile source that
  /// doesn't hit the real network (see `test/fixtures/fake_tile_provider.dart`)
  /// - defaults to the real OSM `NetworkTileProvider` in the app.
  final TileProvider? tileProvider;

  /// Known service-area center shown before a live GPS fix arrives (never
  /// renders a driver marker; only positions the camera over the driver's
  /// operating country/city instead of `(0, 0)`).
  final MapPoint? fallbackCenter;
  final double fallbackZoom;

  /// When `false` (embedded preview map inside a scrollable screen such as
  /// Home), pointer gestures on the map canvas are ignored so vertical drags
  /// always scroll the parent page cleanly. Floating controls (like recenter)
  /// remain tappable.
  final bool interactive;

  final bool showRecenterButton;

  @override
  State<NokiMapView> createState() => _NokiMapViewState();
}

class _NokiMapViewState extends State<NokiMapView> {
  final _controller = MapController();
  bool _fitted = false;

  /// Whether the camera keeps recentering on [widget.driverPosition] as it
  /// updates. Defaults to on; a user pan/zoom gesture turns it off, and
  /// tapping the recenter button turns it back on (mandate: default-follow,
  /// stop on manual gesture, resume+refit on recenter tap).
  bool _following = true;

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
      return;
    }
    final position = widget.driverPosition;
    if (_fitted &&
        _following &&
        position != null &&
        (oldWidget.driverPosition == null ||
            oldWidget.driverPosition!.latitude != position.latitude ||
            oldWidget.driverPosition!.longitude != position.longitude)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _followDriver());
    }
  }

  void _fit() {
    final points = _points;
    if (!mounted) return;
    if (points.isEmpty) {
      if (widget.fallbackCenter != null) {
        _controller.move(
          LatLng(
            widget.fallbackCenter!.latitude,
            widget.fallbackCenter!.longitude,
          ),
          widget.fallbackZoom,
        );
      }
      return;
    }
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

  void _followDriver() {
    final position = widget.driverPosition;
    if (position == null || !mounted) return;
    _controller.move(
      LatLng(position.latitude, position.longitude),
      _controller.camera.zoom,
    );
  }

  void _onRecenter() {
    _following = true;
    _fitted = false;
    _fit();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final points = _points;
    final initialCenter = points.isNotEmpty
        ? LatLng(points.first.latitude, points.first.longitude)
        : widget.fallbackCenter != null
        ? LatLng(
            widget.fallbackCenter!.latitude,
            widget.fallbackCenter!.longitude,
          )
        : const LatLng(0, 0);
    final initialZoom = points.isNotEmpty
        ? 15.0
        : widget.fallbackCenter != null
        ? widget.fallbackZoom
        : 2.0;

    final mapWidget = FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        interactionOptions: InteractionOptions(
          flags: widget.interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
        onPositionChanged: (camera, hasGesture) {
          // A driver-driven pan/zoom stops follow mode; a programmatic
          // move (our own `_fit()`/`_followDriver()` calls) never does.
          if (hasGesture && _following) {
            setState(() => _following = false);
          }
        },
      ),
      children: [
        ColorFiltered(
          colorFilter: isDark ? _darkMapFilter : _lightMapFilter,
          child: _tileLayer(),
        ),
        // Route polyline sits below MarkerLayer (mandate: the route
        // never occludes markers) and is only ever drawn when real
        // backend geometry is supplied - see class doc.
        if (widget.routeGeometry != null && widget.routeGeometry!.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.routeGeometry!
                    .map((p) => LatLng(p.latitude, p.longitude))
                    .toList(),
                strokeWidth: 5,
                color: colors.brandAccent,
                borderStrokeWidth: 2.5,
                borderColor: colors.chromeSurface,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (widget.pickup != null) pickupMarker(widget.pickup!, colors),
            if (widget.dropoff != null) dropoffMarker(widget.dropoff!, colors),
            if (widget.driverPosition != null)
              driverMarker(widget.driverPosition!, colors),
          ],
        ),
        if (widget.interactive)
          SimpleAttributionWidget(
            source: const Text('OpenStreetMap contributors'),
            alignment: Alignment.bottomLeft,
            backgroundColor: colors.surface.withValues(alpha: 0.78),
          ),
      ],
    );

    return Stack(
      children: [
        if (widget.interactive)
          mapWidget
        else
          IgnorePointer(child: mapWidget),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.chromeSurface.withValues(
                      alpha: isDark ? 0.18 : 0.05,
                    ),
                    Colors.transparent,
                    colors.background.withValues(alpha: 0.04),
                    colors.background.withValues(alpha: 0.16),
                  ],
                  stops: const [0, 0.18, 0.72, 1],
                ),
              ),
            ),
          ),
        ),
        if (!widget.interactive)
          PositionedDirectional(
            start: 8,
            bottom: 8,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '© OpenStreetMap',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        if (widget.showRecenterButton)
          PositionedDirectional(
            end: 12,
            bottom: 16,
            child: NokiMapControlButton(
              icon: Icons.my_location_rounded,
              tooltip: AppLocalizations.of(context).mapRecenterAction,
              onPressed: _onRecenter,
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
