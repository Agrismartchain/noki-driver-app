import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/mobility/mobility_offer_poller.dart';
import 'package:noki_driver_app/features/work_feed/work_feed_repository.dart';

import '../../fixtures/fake_driver_api_client.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');
const _pollInterval = Duration(milliseconds: 20);

MobilityRideOfferDto _offer(String id) => MobilityRideOfferDto(
  id: id,
  rideRequestId: 'ride-request-$id',
  driverProfileId: 'driver-1',
  status: MobilityRideOfferDtoStatus.offered,
  offeredAt: '2026-01-01T00:00:00.000Z',
  expiresAt: '2026-01-01T00:00:30.000Z',
  serviceType: MobilityRideOfferDtoServiceType.taxi,
  pickupAddressSnapshot: 'Pickup',
  dropoffAddressSnapshot: 'Dropoff',
);

ProviderContainer _buildContainer(FakeDriverApiClient client) {
  final container = ProviderContainer(
    overrides: [
      driverApiClientProvider.overrideWithValue(client),
      mobilityOfferPollIntervalProvider.overrideWithValue(_pollInterval),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('MobilityOfferPollerController', () {
    test('does not fire an overlapping request while one is still in flight', () async {
      final client = FakeDriverApiClient()
        ..listMobilityOffersResponse = [_offer('offer-1')]
        ..listMobilityOffersDelay = const Duration(milliseconds: 60);
      final container = _buildContainer(client);
      final controller = container.read(mobilityOfferPollerControllerProvider);

      controller.start(_scope);
      // Several poll intervals elapse while the first (slow) call is still
      // pending - none of them should start a second overlapping request.
      await Future<void>.delayed(const Duration(milliseconds: 45));
      expect(client.listMobilityOffersCallCount, 1);

      // Once the in-flight call finishes, the next tick is free to fire.
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(client.listMobilityOffersCallCount, greaterThanOrEqualTo(2));

      controller.stop();
    });

    test('a thrown error on one tick does not prevent the next tick from polling', () async {
      final client = FakeDriverApiClient()
        ..listMobilityOffersError = const AppFailure(AppFailureType.network);
      final container = _buildContainer(client);
      final controller = container.read(mobilityOfferPollerControllerProvider);

      controller.start(_scope);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(client.listMobilityOffersCallCount, greaterThanOrEqualTo(2));

      // Clearing the failure lets a later tick succeed - proof the poller
      // kept going rather than getting stuck after the error.
      client.listMobilityOffersError = null;
      client.listMobilityOffersResponse = [_offer('offer-1')];
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(client.listMobilityOffersCallCount, greaterThanOrEqualTo(3));

      controller.stop();
    });

    test('pauseForBackground stops the timer and resumeForForeground restarts it', () async {
      final client = FakeDriverApiClient()..listMobilityOffersResponse = const [];
      final container = _buildContainer(client);
      final controller = container.read(mobilityOfferPollerControllerProvider);

      controller.start(_scope);
      expect(controller.isPolling, isTrue);

      controller.pauseForBackground();
      expect(controller.isPolling, isFalse);

      final callCountAtPause = client.listMobilityOffersCallCount;
      await Future<void>.delayed(const Duration(milliseconds: 60));
      // No new ticks fire while paused.
      expect(client.listMobilityOffersCallCount, callCountAtPause);

      controller.resumeForForeground();
      expect(controller.isPolling, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(client.listMobilityOffersCallCount, greaterThan(callCountAtPause));

      controller.stop();
    });

    test('stop() cancels the timer so it does not outlive the screen', () {
      final client = FakeDriverApiClient()..listMobilityOffersResponse = const [];
      final container = _buildContainer(client);
      final controller = container.read(mobilityOfferPollerControllerProvider);

      controller.start(_scope);
      expect(controller.isPolling, isTrue);

      controller.stop();
      expect(controller.isPolling, isFalse);
    });

    test('discovering a new offer id invalidates the work feed so it re-fetches', () async {
      final client = FakeDriverApiClient()
        ..workFeedResponse = const DriverWorkFeedListResponseDto(items: [], total: 0, page: 1, pageSize: 25)
        ..listMobilityOffersResponse = const [];
      final container = _buildContainer(client);

      // Keep the work-feed provider alive across the invalidate the same
      // way a mounted Work screen would (autoDispose providers drop their
      // state without an active listener).
      container.listen(workFeedProvider(_scope), (_, _) {}, fireImmediately: true);
      await Future<void>.delayed(Duration.zero);
      expect(client.driverWorkFeedCallCount, 1);

      final controller = container.read(mobilityOfferPollerControllerProvider);
      controller.start(_scope);

      // First tick sees no offers - nothing new, no invalidation.
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(client.driverWorkFeedCallCount, 1);

      // Now an offer appears - the poller should invalidate the work feed.
      client.listMobilityOffersResponse = [_offer('offer-1')];
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(client.driverWorkFeedCallCount, greaterThanOrEqualTo(2));

      controller.stop();
    });
  });
}
