import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/features/map/map_point.dart';
import 'package:noki_driver_app/features/navigation/navigation_route_controller.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';

void main() {
  const target = NavigationTarget(
    destination: MapPoint(33.37, -7.59),
    serviceType: ComputeDriverRouteRequestDtoServiceType.delivery,
  );

  test('two targets differing only in vehicleMode are not equal', () {
    const withCar = NavigationTarget(
      destination: MapPoint(33.37, -7.59),
      serviceType: ComputeDriverRouteRequestDtoServiceType.delivery,
      vehicleMode: ComputeDriverRouteRequestDtoVehicleMode.car,
    );
    const withMotorcycle = NavigationTarget(
      destination: MapPoint(33.37, -7.59),
      serviceType: ComputeDriverRouteRequestDtoServiceType.delivery,
      vehicleMode: ComputeDriverRouteRequestDtoVehicleMode.motorcycle,
    );
    const withNull = NavigationTarget(
      destination: MapPoint(33.37, -7.59),
      serviceType: ComputeDriverRouteRequestDtoServiceType.delivery,
    );

    expect(withCar == withMotorcycle, isFalse);
    expect(withCar == withNull, isFalse);
    expect(withCar.hashCode == withMotorcycle.hashCode, isFalse);
    expect(
      withCar,
      const NavigationTarget(
        destination: MapPoint(33.37, -7.59),
        serviceType: ComputeDriverRouteRequestDtoServiceType.delivery,
        vehicleMode: ComputeDriverRouteRequestDtoVehicleMode.car,
      ),
    );
  });

  ProviderContainer buildContainer(FakeDriverApiClient client) {
    final container = ProviderContainer(
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('fetches immediately on the very first origin update', () async {
    final client = FakeDriverApiClient()
      ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
        sampleComputeRouteResponse(),
      );
    final container = buildContainer(client);

    await container
        .read(navigationRouteControllerProvider(target).notifier)
        .updateOrigin(const MapPoint(33.59, -7.61));

    expect(client.computeRouteCallCount, 1);
    expect(
      container.read(navigationRouteControllerProvider(target)).route?.isOk,
      isTrue,
    );
  });

  test('does not refetch for a sub-threshold movement even after the cooldown elapses', () async {
    final client = FakeDriverApiClient()
      ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
        sampleComputeRouteResponse(),
      );
    final container = buildContainer(client);
    final controller = container.read(
      navigationRouteControllerProvider(target).notifier,
    );
    var now = DateTime(2026, 1, 1, 12);
    controller.nowFn = () => now;

    await controller.updateOrigin(const MapPoint(33.59, -7.61));
    expect(client.computeRouteCallCount, 1);

    // Move ~1m (well under the 150m threshold) and let the cooldown elapse.
    now = now.add(const Duration(minutes: 5));
    await controller.updateOrigin(const MapPoint(33.5901, -7.61));
    expect(client.computeRouteCallCount, 1);
  });

  test(
    'does not refetch for a large movement inside the cooldown window',
    () async {
      final client = FakeDriverApiClient()
        ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
          sampleComputeRouteResponse(),
        );
      final container = buildContainer(client);
      final controller = container.read(
        navigationRouteControllerProvider(target).notifier,
      );
      var now = DateTime(2026, 1, 1, 12);
      controller.nowFn = () => now;

      await controller.updateOrigin(const MapPoint(33.59, -7.61));
      expect(client.computeRouteCallCount, 1);

      // ~2km away (well over the 150m threshold), but only 5s later - inside
      // the 30s cooldown.
      now = now.add(const Duration(seconds: 5));
      await controller.updateOrigin(const MapPoint(33.61, -7.61));
      expect(client.computeRouteCallCount, 1);
    },
  );

  test(
    'refetches once both the distance and cooldown thresholds are satisfied',
    () async {
      final client = FakeDriverApiClient()
        ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
          sampleComputeRouteResponse(),
        );
      final container = buildContainer(client);
      final controller = container.read(
        navigationRouteControllerProvider(target).notifier,
      );
      var now = DateTime(2026, 1, 1, 12);
      controller.nowFn = () => now;

      await controller.updateOrigin(const MapPoint(33.59, -7.61));
      expect(client.computeRouteCallCount, 1);

      now = now.add(const Duration(seconds: 31));
      await controller.updateOrigin(
        const MapPoint(33.61, -7.61),
      ); // ~2.2km away
      expect(client.computeRouteCallCount, 2);
    },
  );

  test('retry bypasses the distance/cooldown thresholds entirely', () async {
    final client = FakeDriverApiClient()
      ..computeRouteResponse = ComputeDriverRouteResponseDto.fromJson(
        sampleComputeRouteResponse(),
      );
    final container = buildContainer(client);
    final controller = container.read(
      navigationRouteControllerProvider(target).notifier,
    );
    var now = DateTime(2026, 1, 1, 12);
    controller.nowFn = () => now;

    await controller.updateOrigin(const MapPoint(33.59, -7.61));
    expect(client.computeRouteCallCount, 1);

    await controller.retry(
      const MapPoint(33.59, -7.61),
    ); // same point, no time elapsed
    expect(client.computeRouteCallCount, 2);
  });
}
