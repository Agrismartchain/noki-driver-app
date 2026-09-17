import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../driver_context/driver_context_repository.dart';
import '../work_feed/work_feed_repository.dart';
import 'mobility_repository.dart';

/// Bounded, automatic polling for Mobility ride-offer discovery.
///
/// Work-feed discovery (`work_feed_screen.dart`) was previously
/// pull-to-refresh only. This controller polls the lean
/// `GET /v1/mobility/driver/offers` endpoint - built specifically "for
/// bounded polling" per its contract summary, unlike the full
/// `/v1/driver/work-feed` aggregation the Work screen renders, which also
/// carries paginated Delivery missions and is too heavy to hit every few
/// seconds - on a fixed interval. When a tick observes an offer id that
/// wasn't present on the previous tick, it invalidates [workFeedProvider]
/// for the active scope so the Work screen (which already renders Mobility
/// offers as `MOBILITY_OFFER` work-feed items) re-fetches and the new offer
/// appears through its existing rendering path. No parallel offer list/UI
/// is built here.
///
/// 7 seconds is chosen as the poll interval: within the requested 5-10s
/// bound, it is frequent enough that a driver sees a new offer well before
/// it would otherwise expire, without being the most aggressive value in
/// the range (battery/data cost on a driver's phone, and load on the
/// endpoint, matter for a polling loop that runs for the driver's entire
/// online session).
///
/// Mirrors [GpsPublisherController]'s foreground-only pause/resume shape
/// (`core/location/gps_publisher.dart`): [HomeShell] calls
/// [pauseForBackground] / [resumeForForeground] from the same
/// `didChangeAppLifecycleState` hook that already drives GPS publishing, so
/// there is one obvious place a future maintainer looks for "what pauses on
/// background".
class MobilityOfferPollerController {
  MobilityOfferPollerController(this._ref, {Duration? pollInterval})
    : _pollInterval = pollInterval ?? const Duration(seconds: 7);

  final Ref _ref;
  final Duration _pollInterval;

  Timer? _timer;
  bool _inFlight = false;
  bool _running = false;
  DriverScope? _scope;
  Set<String> _seenOfferIds = {};

  /// Exposed for tests: whether a timer is currently scheduled.
  bool get isPolling => _timer != null;

  /// Starts polling for [scope]. Called from the Work screen's
  /// `initState()`/`didUpdateWidget()` so the timer's lifecycle is tied to
  /// the screen being mounted and scoped to the active driver context.
  /// Idempotent for the same scope; restarts (resetting "seen" offer state)
  /// if the scope actually changed.
  void start(DriverScope scope) {
    if (_running && _scope == scope) return;
    _scope = scope;
    _running = true;
    _seenOfferIds = {};
    _schedule();
  }

  /// Cancels polling entirely. Called from the Work screen's `dispose()` so
  /// no timer outlives the screen.
  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Called by [HomeShell] on backgrounding - no point polling for offers
  /// the driver can't see or act on while the app isn't visible.
  void pauseForBackground() {
    _timer?.cancel();
    _timer = null;
  }

  /// Called by [HomeShell] on returning to foreground - polls immediately
  /// rather than waiting out whatever remained of the last interval.
  void resumeForForeground() {
    if (!_running || _scope == null) return;
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer.periodic(_pollInterval, (_) => _tick());
  }

  Future<void> _tick() async {
    // One request in flight at a time: skip this tick entirely if the
    // previous one hasn't returned yet, rather than queuing/overlapping.
    if (_inFlight) return;
    final scope = _scope;
    if (scope == null) return;
    _inFlight = true;
    try {
      final offers = await _ref.read(mobilityRepositoryProvider).pollPendingOffers();
      final ids = offers.map((offer) => offer.id).toSet();
      final hasNewOffer = ids.any((id) => !_seenOfferIds.contains(id));
      _seenOfferIds = ids;
      if (hasNewOffer) {
        _ref.invalidate(workFeedProvider(scope));
      }
    } catch (_) {
      // A network error on one tick must never crash the screen or stop
      // future polling - swallow it and let the next tick retry.
    } finally {
      _inFlight = false;
    }
  }

  void dispose() => stop();
}

/// Overridable in tests to use a short interval instead of the production
/// default - see `test/features/mobility/mobility_offer_poller_test.dart`.
final mobilityOfferPollIntervalProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 7);
});

final mobilityOfferPollerControllerProvider = Provider<MobilityOfferPollerController>((ref) {
  final controller = MobilityOfferPollerController(ref, pollInterval: ref.watch(mobilityOfferPollIntervalProvider));
  ref.onDispose(controller.dispose);
  return controller;
});
