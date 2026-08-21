import '../../core/api/generated/driver_models.generated.dart';
import '../map/map_point.dart';

/// One turn-by-turn instruction on a computed route, converted from
/// [NavigationManeuverDto]. Plain domain type - no generated DTO leaks past
/// this file into UI code (mirrors [MapPoint]'s isolation principle).
class NavigationManeuver {
  const NavigationManeuver({
    required this.type,
    this.modifier,
    this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.location,
    this.streetName,
  });

  /// Raw maneuver type string from the routing provider (e.g. "turn",
  /// "depart", "arrive") - not remapped to a closed enum since the backend
  /// contract leaves it open-ended.
  final String type;
  final String? modifier;
  final String? instruction;
  final num distanceMeters;
  final num durationSeconds;
  final MapPoint location;
  final String? streetName;

  factory NavigationManeuver.fromDto(NavigationManeuverDto dto) {
    return NavigationManeuver(
      type: dto.type,
      modifier: dto.modifier,
      instruction: dto.instruction,
      distanceMeters: dto.distanceMeters,
      durationSeconds: dto.durationSeconds,
      location: MapPoint(
        dto.location.latitude.toDouble(),
        dto.location.longitude.toDouble(),
      ),
      streetName: dto.streetName,
    );
  }
}

/// A computed driver route, converted from [ComputeDriverRouteResponseDto].
/// [geometry] is null whenever the backend returned no real routing
/// geometry (unavailable provider, no route found, or a degraded/exception
/// path in [NavigationRouteRepository]) - callers must never fabricate a
/// straight-line fallback for it (mandate §16).
class NavigationRoute {
  const NavigationRoute({
    this.geometry,
    this.distanceMeters,
    this.durationSeconds,
    this.profile,
    this.maneuvers = const [],
    required this.providerStatus,
  });

  final List<MapPoint>? geometry;
  final num? distanceMeters;
  final num? durationSeconds;
  final ComputeDriverRouteResponseDtoProfile? profile;
  final List<NavigationManeuver> maneuvers;
  final ComputeDriverRouteResponseDtoProviderStatus providerStatus;

  /// True only when the provider genuinely returned usable geometry - the
  /// single condition [NokiMapView] is allowed to draw a route polyline on.
  bool get hasGeometry => geometry != null && geometry!.isNotEmpty;

  bool get isOk =>
      providerStatus == ComputeDriverRouteResponseDtoProviderStatus.ok;

  factory NavigationRoute.fromDto(ComputeDriverRouteResponseDto dto) {
    return NavigationRoute(
      // GeoJSON coordinates are [lng, lat] pairs per the contract - flipped
      // here, once, so every downstream consumer works in (lat, lng).
      geometry: dto.geometry?.coordinates
          .map((c) => MapPoint(c[1].toDouble(), c[0].toDouble()))
          .toList(),
      distanceMeters: dto.distanceMeters,
      durationSeconds: dto.durationSeconds,
      profile: dto.profile,
      maneuvers: dto.maneuvers.map(NavigationManeuver.fromDto).toList(),
      providerStatus: dto.providerStatus,
    );
  }

  /// A degraded route with no geometry - used whenever the repository
  /// cannot honestly report a real backend provider status (a thrown
  /// exception, not a well-formed `providerStatus` in the response).
  const NavigationRoute.unavailable()
    : geometry = null,
      distanceMeters = null,
      durationSeconds = null,
      profile = null,
      maneuvers = const [],
      providerStatus =
          ComputeDriverRouteResponseDtoProviderStatus.providerUnavailable;
}
