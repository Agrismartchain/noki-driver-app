import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/driver_context/driver_context_repository.dart';
import '../api/api_providers.dart';
import '../api/generated/driver_models.generated.dart';
import 'gps_publish_policy.dart';
import 'location_repository.dart';

/// GPS publisher (mandate §8-10, B4/DRV-05). One live position stream,
/// restarted only when the cadence or the background keep-alive actually
/// changes, stopped entirely when the driver isn't tracked. Publish failures
/// are swallowed - a flaky network must never surface as a blocking error to
/// a driver mid-delivery; the next successful ping simply catches state up.
///
/// Two properties dispatch depends on (the server drops a driver whose last
/// fix is older than MOBILITY_DRIVER_LOCATION_MAX_AGE_SECONDS, default 120s):
///  * HEARTBEAT: a distance-filtered stream emits nothing while the driver is
///    stationary, which would silently age an available driver out of
///    dispatch. A timer therefore re-publishes the current position every
///    cadence interval even without movement.
///  * ACTIVE-WORK BACKGROUND: on an accepted ride / mission the stream is kept
///    alive in the background (Android foreground service / iOS background
///    location) so tracking survives a locked screen. Idle availability stays
///    foreground-only - [HomeShell] stops it on `AppLifecycleState.paused`.
class GpsPublisherController {
  GpsPublisherController(this._ref);

  final Ref _ref;
  StreamSubscription<Position>? _subscription;
  DateTime? _lastPublishedAt;
  int? _activeDistanceFilterMeters;
  bool _activeKeepAlive = false;
  Timer? _heartbeat;
  DriverTrackingContext _context = DriverTrackingContext.offline;

  DriverTrackingContext get context => _context;

  void updateContext(DriverTrackingContext context) {
    _context = context;
    final cadence = GpsPublishPolicy.cadenceFor(context);
    if (cadence == null) {
      _stopStream();
      return;
    }
    final keepAlive = context.hasActiveWork;
    if (_activeDistanceFilterMeters != cadence.distanceFilterMeters ||
        _activeKeepAlive != keepAlive) {
      _restartStream(cadence, keepAlive);
    }
  }

  void _restartStream(GpsCadence cadence, bool keepAlive) {
    _subscription?.cancel();
    _heartbeat?.cancel();
    _activeDistanceFilterMeters = cadence.distanceFilterMeters;
    _activeKeepAlive = keepAlive;
    _subscription = _ref
        .read(locationRepositoryProvider)
        .positionStream(
          distanceFilterMeters: cadence.distanceFilterMeters,
          keepAliveInBackground: keepAlive,
        )
        .listen(_onPosition, onError: (Object _, StackTrace _) {});
    _heartbeat = Timer.periodic(cadence.minInterval, (_) => _beat());
  }

  /// Re-publishes the current position when the stream has been silent for a
  /// full interval (stationary driver), so the server-side fix never ages out.
  Future<void> _beat() async {
    final cadence = GpsPublishPolicy.cadenceFor(_context);
    if (cadence == null) return;
    final last = _lastPublishedAt;
    // Moving drivers already publish through the stream; only fill the gaps.
    if (last != null &&
        _ref.read(gpsClockProvider)().difference(last) <
            cadence.minInterval ~/ 2) {
      return;
    }
    try {
      final position = await _ref
          .read(locationRepositoryProvider)
          .currentPosition();
      await _onPosition(position, force: true);
    } catch (_) {
      // No fix this tick (indoors / permission revoked): try again next beat.
    }
  }

  void _stopStream() {
    _subscription?.cancel();
    _subscription = null;
    _heartbeat?.cancel();
    _heartbeat = null;
    _activeDistanceFilterMeters = null;
    _activeKeepAlive = false;
  }

  /// Called by [HomeShell] on backgrounding. Idle availability tracking stops
  /// (foreground-only); a stream that was started with background keep-alive
  /// for ACTIVE work (ride / mission in progress) is deliberately left running.
  void pauseForBackground() {
    if (_context.hasActiveWork && _activeKeepAlive) return;
    _stopStream();
  }

  /// Called on returning to foreground - re-evaluates the current context.
  void resumeForForeground() => updateContext(_context);

  Future<void> _onPosition(Position position, {bool force = false}) async {
    final cadence = GpsPublishPolicy.cadenceFor(_context);
    if (cadence == null) return;
    final now = _ref.read(gpsClockProvider)();
    if (!force &&
        !GpsPublishPolicy.shouldPublish(
          cadence: cadence,
          lastPublishedAt: _lastPublishedAt,
          now: now,
        )) {
      return;
    }
    _lastPublishedAt = now;

    final client = _ref.read(driverApiClientProvider);
    final ctx = _context;
    final recordedAt = now.toUtc().toIso8601String();

    try {
      if (ctx.activeRideId != null) {
        await client.submitMobilityLocation(
          _mobilityPoint(position, recordedAt, rideId: ctx.activeRideId),
        );
      } else if (ctx.activeMissionId != null) {
        if (ctx.scope != null) {
          await client.submitDeliveryLocation(
            _deliveryPayload(
              position,
              recordedAt,
              ctx.scope!,
              shipmentId: ctx.activeMissionId,
            ),
          );
        }
      } else {
        if (ctx.mobilityAvailable) {
          await client.submitMobilityLocation(
            _mobilityPoint(position, recordedAt, rideId: null),
          );
        }
        if (ctx.deliveryAvailable && ctx.scope != null) {
          await client.submitDeliveryLocation(
            _deliveryPayload(
              position,
              recordedAt,
              ctx.scope!,
              shipmentId: null,
            ),
          );
        }
      }
    } catch (_) {
      // Best-effort publish - see class doc.
    }
  }

  SubmitMobilityLocationDto _mobilityPoint(
    Position position,
    String recordedAt, {
    String? rideId,
  }) {
    return SubmitMobilityLocationDto(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      headingDegrees: position.heading,
      speedKph: position.speed * 3.6,
      recordedAt: recordedAt,
      rideId: rideId,
    );
  }

  SubmitDeliveryLocationDto _deliveryPayload(
    Position position,
    String recordedAt,
    DriverScope scope, {
    String? shipmentId,
  }) {
    return SubmitDeliveryLocationDto(
      organizationId: scope.organizationId,
      countryCode: scope.countryCode,
      points: [
        DeliveryLocationPointInputDto(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
          headingDegrees: position.heading,
          speedKph: position.speed * 3.6,
          recordedAt: recordedAt,
          shipmentId: shipmentId,
        ),
      ],
    );
  }

  void dispose() => _stopStream();
}

/// Wall clock used for publish throttling; overridable so cadence / heartbeat
/// behaviour is testable without real waiting.
final gpsClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final gpsPublisherControllerProvider = Provider<GpsPublisherController>((ref) {
  final controller = GpsPublisherController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});
