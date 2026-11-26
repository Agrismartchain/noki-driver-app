import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/location/gps_publish_policy.dart';
import 'package:noki_driver_app/core/location/gps_publisher.dart';
import 'package:noki_driver_app/core/location/location_repository.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/fake_location_repository.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

Position _realDevicePosition() => Position(
  latitude: -4.2634,
  longitude: 15.2429,
  timestamp: DateTime(2026, 1, 1),
  accuracy: 8,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 214.75,
  headingAccuracy: 0,
  speed: 6.25, // m/s
  speedAccuracy: 0,
);

void main() {
  group('GpsPublisherController delivery ping telemetry', () {
    test('sends real device heading and speed alongside coordinates and accuracy', () async {
      final client = FakeDriverApiClient()
        ..submitDeliveryLocationResponse = const SubmitDeliveryLocationResponseDto(accepted: 1, lastLocationAt: '2026-01-01T00:00:00.000Z');
      final locationRepository = FakeLocationRepository()..position = _realDevicePosition();
      final container = ProviderContainer(
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(locationRepository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(gpsPublisherControllerProvider);
      controller.updateContext(
        const DriverTrackingContext(scope: _scope, activeMissionId: 'mission-1'),
      );
      // The position stream emits synchronously but _onPosition is async;
      // let its microtasks/await chain settle.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final request = client.lastSubmitDeliveryLocationRequest;
      expect(request, isNotNull);
      final point = request!.points.single;
      expect(point.latitude, -4.2634);
      expect(point.longitude, 15.2429);
      expect(point.accuracyMeters, 8);
      expect(point.headingDegrees, 214.75);
      // geolocator reports speed in m/s; the wire contract is km/h.
      expect(point.speedKph, closeTo(22.5, 0.01));
      expect(point.shipmentId, 'mission-1');
    });

    test('still sends mobility telemetry unaffected by the delivery payload change', () async {
      final client = FakeDriverApiClient()
        ..submitMobilityLocationResponse = MobilityDriverDto.fromJson({
          'id': 'driver-1',
          'code': 'DRV-1',
          'displayName': 'Test Driver',
          'organizationName': 'Org',
          'countryCode': 'MA',
          'onboardingStatus': 'APPROVED',
          'operationalStatus': 'ACTIVE',
          'availabilityStatus': 'AVAILABLE',
          'allowedServiceTypes': <String>[],
          'operatingZoneIds': <String>[],
          'ratingCount': 0,
          'ridesCount': 0,
          'updatedAt': '2026-01-01T00:00:00.000Z',
        });
      final locationRepository = FakeLocationRepository()..position = _realDevicePosition();
      final container = ProviderContainer(
        overrides: [
          driverApiClientProvider.overrideWithValue(client),
          locationRepositoryProvider.overrideWithValue(locationRepository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(gpsPublisherControllerProvider);
      controller.updateContext(
        const DriverTrackingContext(scope: _scope, activeRideId: 'ride-1'),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final request = client.lastSubmitMobilityLocationRequest;
      expect(request, isNotNull);
      expect(request!.headingDegrees, 214.75);
      expect(request.speedKph, closeTo(22.5, 0.01));
      expect(request.rideId, 'ride-1');
    });
  });

  group('GpsPublisherController foreground-only lifecycle', () {
    // Mirrors MobilityOfferPollerController's own pause/resume test
    // (mobility_offer_poller_test.dart) - HomeShell drives both controllers
    // from the exact same didChangeAppLifecycleState hook, but until now
    // only the offer poller side of that contract had any direct coverage.
    test(
      'pauseForBackground stops the position stream; resumeForForeground '
      're-subscribes and picks up the driver\'s current position',
      () async {
        final client = FakeDriverApiClient()
          ..submitDeliveryLocationResponse = const SubmitDeliveryLocationResponseDto(
            accepted: 1,
            lastLocationAt: '2026-01-01T00:00:00.000Z',
          );
        final locationRepository = FakeLocationRepository()
          ..position = _realDevicePosition();
        final container = ProviderContainer(
          overrides: [
            driverApiClientProvider.overrideWithValue(client),
            locationRepositoryProvider.overrideWithValue(locationRepository),
          ],
        );
        addTearDown(container.dispose);

        // A fixed, test-controlled clock: the real GpsPublishPolicy cadence
        // floor (20s for active work) must not force this test to actually
        // wait 20 real seconds just to prove resumeForForeground publishes
        // again - see GpsPublisherController.nowFn's doc comment.
        var now = DateTime(2026, 1, 1, 12, 0, 0);
        final controller = container.read(gpsPublisherControllerProvider)
          ..nowFn = () => now;
        controller.updateContext(
          const DriverTrackingContext(scope: _scope, activeMissionId: 'mission-1'),
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        expect(client.lastSubmitDeliveryLocationRequest, isNotNull);
        expect(client.lastSubmitDeliveryLocationRequest!.points.single.latitude, -4.2634);

        // Background: the app is no longer foreground, so the stream must
        // actually stop - not merely withhold a publish.
        controller.pauseForBackground();
        client.lastSubmitDeliveryLocationRequest = null;

        // The driver kept moving while backgrounded (foreground-only
        // tracking per mandate - never published while paused).
        locationRepository.position = Position(
          latitude: -4.3000,
          longitude: 15.3000,
          timestamp: DateTime(2026, 1, 1),
          accuracy: 8,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 90,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );

        // The driver was away long enough for the cadence floor to clear -
        // a real background/foreground cycle is rarely faster than the
        // active-work floor (20s) anyway.
        now = now.add(const Duration(seconds: 25));

        // Foreground again: must re-subscribe and publish the driver's
        // *current* position, not something stale from before pausing - if
        // pauseForBackground had been a no-op, this call would see an
        // unchanged cadence and skip re-subscribing entirely, and the
        // assertion below would correctly fail.
        controller.resumeForForeground();
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(client.lastSubmitDeliveryLocationRequest, isNotNull);
        expect(
          client.lastSubmitDeliveryLocationRequest!.points.single.latitude,
          -4.3000,
          reason: 'resumeForForeground must re-subscribe to live position, '
              'not replay a stale pre-pause value',
        );
      },
    );
  });
}
