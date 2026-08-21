import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../map/map_point.dart';
import 'navigation_route.dart';
import 'navigation_route_repository.dart';

/// Minimum driver movement, in meters, since the route-relevant origin last
/// used to compute a route before a new computation is even considered
/// (mandate §40/§41). Ordinary GPS jitter is single digits of meters and a
/// driver briefly stopped at a light shouldn't recompute at all - 150m is
/// roughly one city block, enough to catch a genuine deviation (a missed
/// turn, a detour) without chasing every GPS update.
const kNavigationDeviationDistanceMeters = 150.0;

/// Minimum time between two route recomputes, regardless of distance moved.
/// Combined with [kNavigationDeviationDistanceMeters] this guarantees
/// navigation can never fire a routing request on every GPS tick, even for a
/// driver moving fast enough to cross the distance threshold every few
/// seconds (e.g. a taxi on a highway) - both conditions must hold.
const kNavigationRecomputeCooldown = Duration(seconds: 30);

/// The fixed destination + service type a screen wants routed - equality is
/// structural so the same mission/ride keeps reusing one controller instance
/// across rebuilds instead of creating a new provider per frame.
class NavigationTarget {
  const NavigationTarget({
    required this.destination,
    required this.serviceType,
    this.vehicleMode,
  });

  final MapPoint destination;
  final ComputeDriverRouteRequestDtoServiceType serviceType;

  /// Only meaningful for `DELIVERY` - the backend ignores it for
  /// `TAXI`/`TAXI_MOTO` (those always route as car/motorcycle respectively).
  /// Null when no authoritative vehicle context is available; never guessed.
  final ComputeDriverRouteRequestDtoVehicleMode? vehicleMode;

  @override
  bool operator ==(Object other) =>
      other is NavigationTarget &&
      other.destination.latitude == destination.latitude &&
      other.destination.longitude == destination.longitude &&
      other.serviceType == serviceType &&
      other.vehicleMode == vehicleMode;

  @override
  int get hashCode => Object.hash(
    destination.latitude,
    destination.longitude,
    serviceType,
    vehicleMode,
  );
}

class NavigationRouteState {
  const NavigationRouteState({this.route, this.isLoading = false});

  /// Null until the first fetch completes.
  final NavigationRoute? route;
  final bool isLoading;

  NavigationRouteState copyWith({NavigationRoute? route, bool? isLoading}) {
    return NavigationRouteState(
      route: route ?? this.route,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Owns the current [NavigationRoute] for one screen's fixed [NavigationTarget]:
/// fetches once the first driver position is known, then reapplies the
/// bounded deviation policy above on every subsequent position update
/// instead of recomputing on each GPS tick. Screens call [updateOrigin] from
/// wherever they already watch `livePositionProvider`, and [retry] from the
/// manual retry affordance shown when `providerStatus != ok`.
class NavigationRouteController
    extends AutoDisposeFamilyNotifier<NavigationRouteState, NavigationTarget> {
  MapPoint? _lastOrigin;
  DateTime? _lastFetchedAt;

  /// Overridable clock, test-only - defaults to the real wall clock. Lets
  /// the deviation/cooldown policy be exercised deterministically (see
  /// `navigation_route_controller_test.dart`) without waiting on real time.
  @visibleForTesting
  DateTime Function() nowFn = DateTime.now;

  @override
  NavigationRouteState build(NavigationTarget arg) {
    return const NavigationRouteState();
  }

  /// Called with the latest known driver position. Fetches immediately the
  /// first time it's called for this target; afterwards only recomputes once
  /// both the distance and cooldown thresholds are satisfied.
  Future<void> updateOrigin(MapPoint origin) async {
    if (!_shouldFetch(origin, nowFn())) return;
    await _fetch(origin);
  }

  /// Manual retry affordance - bypasses the distance/cooldown thresholds
  /// entirely, since it's an explicit driver action, not a background tick.
  Future<void> retry(MapPoint origin) => _fetch(origin);

  bool _shouldFetch(MapPoint origin, DateTime now) {
    final lastOrigin = _lastOrigin;
    if (lastOrigin == null) return true;
    final movedEnough =
        _distanceMeters(lastOrigin, origin) >=
        kNavigationDeviationDistanceMeters;
    final cooldownElapsed =
        _lastFetchedAt == null ||
        now.difference(_lastFetchedAt!) >= kNavigationRecomputeCooldown;
    return movedEnough && cooldownElapsed;
  }

  Future<void> _fetch(MapPoint origin) async {
    _lastOrigin = origin;
    _lastFetchedAt = nowFn();
    state = state.copyWith(isLoading: true);
    final route = await ref
        .read(navigationRouteRepositoryProvider)
        .computeRoute(
          origin: origin,
          destination: arg.destination,
          serviceType: arg.serviceType,
          vehicleMode: arg.vehicleMode,
        );
    state = NavigationRouteState(route: route, isLoading: false);
  }
}

final navigationRouteControllerProvider = NotifierProvider.autoDispose
    .family<NavigationRouteController, NavigationRouteState, NavigationTarget>(
      NavigationRouteController.new,
    );

/// Plain haversine distance in meters - deliberately independent of
/// `latlong2`/`flutter_map` so this domain layer never imports either
/// (mirrors [MapPoint]'s isolation principle).
double _distanceMeters(MapPoint a, MapPoint b) {
  const earthRadiusMeters = 6371000.0;
  final dLat = _degToRad(b.latitude - a.latitude);
  final dLon = _degToRad(b.longitude - a.longitude);
  final lat1 = _degToRad(a.latitude);
  final lat2 = _degToRad(b.latitude);
  final h =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  return earthRadiusMeters * c;
}

double _degToRad(double deg) => deg * (math.pi / 180.0);
