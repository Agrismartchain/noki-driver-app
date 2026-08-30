import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/driver_context/driver_context_repository.dart';
import '../api/api_providers.dart';
import '../api/generated/driver_models.generated.dart';
import 'gps_publish_policy.dart';
import 'location_repository.dart';

/// Foreground-only GPS publisher (mandate §8-10). One live position stream,
/// restarted only when the cadence actually changes, stopped entirely when
/// the driver isn't tracked. Publish failures are swallowed - a flaky
/// network must never surface as a blocking error to a driver mid-delivery;
/// the next successful ping simply catches state up.
///
/// [BACKGROUND_GPS] is explicitly not implemented this phase - see the
/// DRIVER-APP-03 final report. This controller only runs while the app is
/// in the foreground; [HomeShell] stops it on `AppLifecycleState.paused`.
class GpsPublisherController {
  GpsPublisherController(this._ref);

  final Ref _ref;
  StreamSubscription<Position>? _subscription;
  DateTime? _lastPublishedAt;
  int? _activeDistanceFilterMeters;
  DriverTrackingContext _context = DriverTrackingContext.offline;

  DriverTrackingContext get context => _context;

  void updateContext(DriverTrackingContext context) {
    _context = context;
    final cadence = GpsPublishPolicy.cadenceFor(context);
    if (cadence == null) {
      _stopStream();
      return;
    }
    if (_activeDistanceFilterMeters != cadence.distanceFilterMeters) {
      _restartStream(cadence.distanceFilterMeters);
    }
  }

  void _restartStream(int distanceFilterMeters) {
    _subscription?.cancel();
    _activeDistanceFilterMeters = distanceFilterMeters;
    _subscription = _ref
        .read(locationRepositoryProvider)
        .positionStream(distanceFilterMeters: distanceFilterMeters)
        .listen(_onPosition, onError: (Object _, StackTrace _) {});
  }

  void _stopStream() {
    _subscription?.cancel();
    _subscription = null;
    _activeDistanceFilterMeters = null;
  }

  /// Called by [HomeShell] on backgrounding - foreground-only per mandate.
  void pauseForBackground() => _stopStream();

  /// Called on returning to foreground - re-evaluates the current context.
  void resumeForForeground() => updateContext(_context);

  Future<void> _onPosition(Position position) async {
    final cadence = GpsPublishPolicy.cadenceFor(_context);
    if (cadence == null) return;
    final now = DateTime.now();
    if (!GpsPublishPolicy.shouldPublish(cadence: cadence, lastPublishedAt: _lastPublishedAt, now: now)) {
      return;
    }
    _lastPublishedAt = now;

    final client = _ref.read(driverApiClientProvider);
    final ctx = _context;
    final recordedAt = now.toUtc().toIso8601String();

    try {
      if (ctx.activeRideId != null) {
        await client.submitMobilityLocation(_mobilityPoint(position, recordedAt, rideId: ctx.activeRideId));
      } else if (ctx.activeMissionId != null) {
        if (ctx.scope != null) {
          await client.submitDeliveryLocation(_deliveryPayload(position, recordedAt, ctx.scope!, shipmentId: ctx.activeMissionId));
        }
      } else {
        if (ctx.mobilityAvailable) {
          await client.submitMobilityLocation(_mobilityPoint(position, recordedAt, rideId: null));
        }
        if (ctx.deliveryAvailable && ctx.scope != null) {
          await client.submitDeliveryLocation(_deliveryPayload(position, recordedAt, ctx.scope!, shipmentId: null));
        }
      }
    } catch (_) {
      // Best-effort publish - see class doc.
    }
  }

  SubmitMobilityLocationDto _mobilityPoint(Position position, String recordedAt, {String? rideId}) {
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

  SubmitDeliveryLocationDto _deliveryPayload(Position position, String recordedAt, DriverScope scope, {String? shipmentId}) {
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

final gpsPublisherControllerProvider = Provider<GpsPublisherController>((ref) {
  final controller = GpsPublisherController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});
