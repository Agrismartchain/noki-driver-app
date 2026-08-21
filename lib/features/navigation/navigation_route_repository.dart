import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/driver_api_client.dart';
import '../../core/api/generated/driver_models.generated.dart';
import '../map/map_point.dart';
import 'navigation_route.dart';

/// Computes an in-app route between two points via the backend routing
/// endpoint (`POST /v1/driver/navigation/route`). Never throws: any
/// [AppFailure] or other thrown exception (timeout, malformed response, no
/// network) degrades to [NavigationRoute.unavailable] instead of surfacing
/// as an error the mission/ride map screen has to special-case - the mission
/// remains fully accessible even when routing is down (mandate §51).
class NavigationRouteRepository {
  NavigationRouteRepository(this._client);

  final DriverApiClient _client;

  Future<NavigationRoute> computeRoute({
    required MapPoint origin,
    required MapPoint destination,
    required ComputeDriverRouteRequestDtoServiceType serviceType,
  }) async {
    try {
      final response = await _client.computeRoute(
        ComputeDriverRouteRequestDto(
          origin: NavigationGeoPointInputDto(
            latitude: origin.latitude,
            longitude: origin.longitude,
          ),
          destination: NavigationGeoPointInputDto(
            latitude: destination.latitude,
            longitude: destination.longitude,
          ),
          serviceType: serviceType,
        ),
      );
      return NavigationRoute.fromDto(response);
    } catch (_) {
      return const NavigationRoute.unavailable();
    }
  }
}

final navigationRouteRepositoryProvider = Provider<NavigationRouteRepository>((
  ref,
) {
  return NavigationRouteRepository(ref.watch(driverApiClientProvider));
});
