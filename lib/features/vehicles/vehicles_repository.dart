import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/driver_api_client.dart';
import '../../core/api/generated/driver_models.generated.dart';
import '../driver_context/driver_context_repository.dart';

class VehiclesRepository {
  VehiclesRepository(this._client);

  final DriverApiClient _client;

  Future<DriverVehicleListResponseDto> fetch(DriverScope scope) {
    return _client.driverVehicles(organizationId: scope.organizationId, countryCode: scope.countryCode);
  }
}

final vehiclesRepositoryProvider = Provider<VehiclesRepository>((ref) {
  return VehiclesRepository(ref.watch(driverApiClientProvider));
});

final vehiclesProvider = FutureProvider.autoDispose.family<DriverVehicleListResponseDto, DriverScope>(
  (ref, scope) => ref.watch(vehiclesRepositoryProvider).fetch(scope),
);
