import '../../features/driver_context/driver_context_repository.dart';

/// What the driver is doing right now, as far as GPS publishing cares. Set
/// explicitly by whichever screen is active - Home for the idle/available
/// case, the Delivery/Mobility active-work screens once a mission/ride is
/// open - never inferred from global app state (mandate §8/§34).
class DriverTrackingContext {
  const DriverTrackingContext({
    this.scope,
    this.deliveryAvailable = false,
    this.mobilityAvailable = false,
    this.activeMissionId,
    this.activeRideId,
  });

  /// Driver is not tracked at all: offline, or Home not yet loaded.
  static const offline = DriverTrackingContext();

  final DriverScope? scope;
  final bool deliveryAvailable;
  final bool mobilityAvailable;
  final String? activeMissionId;
  final String? activeRideId;

  bool get hasActiveWork => activeMissionId != null || activeRideId != null;
  bool get isTracked => hasActiveWork || deliveryAvailable || mobilityAvailable;
}

class GpsCadence {
  const GpsCadence({required this.distanceFilterMeters, required this.minInterval});

  final int distanceFilterMeters;
  final Duration minInterval;
}

/// A battery-conscious V1 GPS cadence (mandate §9): available-but-idle
/// drivers are tracked coarsely (50m movement, 60s floor); a driver on an
/// active Delivery or Ride is tracked more tightly (15m movement, 20s
/// floor). Never a fixed animation-frame loop.
class GpsPublishPolicy {
  static const idle = GpsCadence(distanceFilterMeters: 50, minInterval: Duration(seconds: 60));
  static const active = GpsCadence(distanceFilterMeters: 15, minInterval: Duration(seconds: 20));

  /// `null` means: don't track at all (driver offline, no active work).
  static GpsCadence? cadenceFor(DriverTrackingContext context) {
    if (!context.isTracked) return null;
    return context.hasActiveWork ? active : idle;
  }

  static bool shouldPublish({required GpsCadence cadence, required DateTime? lastPublishedAt, required DateTime now}) {
    if (lastPublishedAt == null) return true;
    return now.difference(lastPublishedAt) >= cadence.minInterval;
  }
}
