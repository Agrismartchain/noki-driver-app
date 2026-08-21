import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/features/map/map_point.dart';
import 'package:noki_driver_app/features/navigation/navigation_route_repository.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';

void main() {
  const origin = MapPoint(33.59, -7.61);
  const destination = MapPoint(33.37, -7.59);

  test('maps a real OK response to a NavigationRoute with lat/lng-flipped geometry', () async {
    final client = FakeDriverApiClient()
      ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
        sampleComputeRouteResponse(),
      );
    final repository = NavigationRouteRepository(client);

    final route = await repository.computeRoute(
      origin: origin,
      destination: destination,
      serviceType: ComputeDriverRouteRequestDtoServiceType.delivery,
    );

    expect(
      route.providerStatus,
      ComputeDriverRouteResponseDtoProviderStatus.ok,
    );
    expect(route.isOk, isTrue);
    expect(route.hasGeometry, isTrue);
    // GeoJSON coordinates are [lng, lat] - the domain model must flip them.
    expect(route.geometry!.first.latitude, 33.59);
    expect(route.geometry!.first.longitude, -7.61);
    expect(route.distanceMeters, 24100);
    expect(route.durationSeconds, 1800);
    expect(route.profile, ComputeDriverRouteResponseDtoProfile.auto);
    expect(route.maneuvers, hasLength(1));
    expect(
      route.maneuvers.first.instruction,
      'Turn right onto Boulevard Zerktouni',
    );
    expect(route.maneuvers.first.location.latitude, 33.585);

    expect(client.lastComputeRouteRequest?.origin.latitude, origin.latitude);
    expect(
      client.lastComputeRouteRequest?.destination.latitude,
      destination.latitude,
    );
    expect(
      client.lastComputeRouteRequest?.serviceType,
      ComputeDriverRouteRequestDtoServiceType.delivery,
    );
  });

  test('a null geometry response maps to a route with no geometry (never a fabricated line)', () async {
    final client = FakeDriverApiClient()
      ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
        sampleComputeRouteResponse(
          providerStatus: 'NO_ROUTE',
          withGeometry: false,
        ),
      );
    final repository = NavigationRouteRepository(client);

    final route = await repository.computeRoute(
      origin: origin,
      destination: destination,
      serviceType: ComputeDriverRouteRequestDtoServiceType.taxi,
    );

    expect(route.geometry, isNull);
    expect(route.hasGeometry, isFalse);
    expect(
      route.providerStatus,
      ComputeDriverRouteResponseDtoProviderStatus.noRoute,
    );
    expect(route.isOk, isFalse);
  });

  test(
    'providerStatus passes through untouched for every non-OK value',
    () async {
      for (final status in ['PROVIDER_UNAVAILABLE', 'TIMEOUT']) {
        final client = FakeDriverApiClient()
          ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
            sampleComputeRouteResponse(
              providerStatus: status,
              withGeometry: false,
            ),
          );
        final repository = NavigationRouteRepository(client);

        final route = await repository.computeRoute(
          origin: origin,
          destination: destination,
          serviceType: ComputeDriverRouteRequestDtoServiceType.taxiMoto,
        );

        expect(
          route.providerStatus.name,
          status == 'PROVIDER_UNAVAILABLE' ? 'providerUnavailable' : 'timeout',
        );
      }
    },
  );

  test('an AppFailure from the client degrades to an unavailable route, never throws', () async {
    final client = FakeDriverApiClient()
      ..computeRouteFailure = const AppFailure(AppFailureType.server);
    final repository = NavigationRouteRepository(client);

    final route = await repository.computeRoute(
      origin: origin,
      destination: destination,
      serviceType: ComputeDriverRouteRequestDtoServiceType.delivery,
    );

    expect(route.hasGeometry, isFalse);
    expect(
      route.providerStatus,
      ComputeDriverRouteResponseDtoProviderStatus.providerUnavailable,
    );
  });

  test('an unset response (a thrown null-check, not an AppFailure) also degrades instead of throwing', () async {
    final client = FakeDriverApiClient(); // computeRouteResponse left null
    final repository = NavigationRouteRepository(client);

    final route = await repository.computeRoute(
      origin: origin,
      destination: destination,
      serviceType: ComputeDriverRouteRequestDtoServiceType.delivery,
    );

    expect(route.hasGeometry, isFalse);
    expect(
      route.providerStatus,
      ComputeDriverRouteResponseDtoProviderStatus.providerUnavailable,
    );
  });
}
