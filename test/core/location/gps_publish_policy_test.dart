import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/location/gps_publish_policy.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  group('GpsPublishPolicy.cadenceFor', () {
    test('an untracked driver (offline, no active work) is not tracked at all', () {
      expect(GpsPublishPolicy.cadenceFor(DriverTrackingContext.offline), isNull);
    });

    test('AVAILABLE with no active work uses the coarse idle cadence', () {
      final cadence = GpsPublishPolicy.cadenceFor(
        const DriverTrackingContext(scope: _scope, mobilityAvailable: true),
      );
      expect(cadence, GpsPublishPolicy.idle);
    });

    test('an active Delivery mission uses the tighter active cadence, even if not "available"', () {
      final cadence = GpsPublishPolicy.cadenceFor(
        const DriverTrackingContext(scope: _scope, activeMissionId: 'mission-1'),
      );
      expect(cadence, GpsPublishPolicy.active);
    });

    test('an active Ride uses the tighter active cadence', () {
      final cadence = GpsPublishPolicy.cadenceFor(
        const DriverTrackingContext(scope: _scope, activeRideId: 'ride-1'),
      );
      expect(cadence, GpsPublishPolicy.active);
    });

    test('active work wins over idle availability when both happen to be set', () {
      final cadence = GpsPublishPolicy.cadenceFor(
        const DriverTrackingContext(scope: _scope, mobilityAvailable: true, activeRideId: 'ride-1'),
      );
      expect(cadence, GpsPublishPolicy.active);
    });
  });

  group('GpsPublishPolicy.shouldPublish', () {
    final now = DateTime(2026, 1, 1, 12, 0, 0);

    test('always publishes the first position (no prior publish)', () {
      final result = GpsPublishPolicy.shouldPublish(cadence: GpsPublishPolicy.idle, lastPublishedAt: null, now: now);
      expect(result, isTrue);
    });

    test('withholds a publish before the cadence floor has elapsed', () {
      final result = GpsPublishPolicy.shouldPublish(
        cadence: GpsPublishPolicy.active, // 20s floor
        lastPublishedAt: now.subtract(const Duration(seconds: 10)),
        now: now,
      );
      expect(result, isFalse);
    });

    test('allows a publish once the cadence floor has elapsed', () {
      final result = GpsPublishPolicy.shouldPublish(
        cadence: GpsPublishPolicy.active,
        lastPublishedAt: now.subtract(const Duration(seconds: 20)),
        now: now,
      );
      expect(result, isTrue);
    });

    test('the idle cadence has a longer floor than the active cadence (battery-conscious)', () {
      expect(GpsPublishPolicy.idle.minInterval, greaterThan(GpsPublishPolicy.active.minInterval));
      expect(GpsPublishPolicy.idle.distanceFilterMeters, greaterThan(GpsPublishPolicy.active.distanceFilterMeters));
    });
  });
}
