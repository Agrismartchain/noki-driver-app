import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/driver_api_client.dart';
import '../../core/api/generated/driver_models.generated.dart';
import '../driver_context/driver_context_repository.dart';

class AvailabilityRepository {
  AvailabilityRepository(this._client);

  final DriverApiClient _client;

  Future<DriverAvailabilityResponseDto> fetch(DriverScope scope) {
    return _client.driverAvailability(organizationId: scope.organizationId, countryCode: scope.countryCode);
  }

  Future<DriverAvailabilityResponseDto> update(
    DriverScope scope,
    UpdateDriverAvailabilityDtoAvailabilityStatus status,
  ) {
    return _client.updateDriverAvailability(
      UpdateDriverAvailabilityDto(
        organizationId: scope.organizationId,
        countryCode: scope.countryCode,
        availabilityStatus: status,
      ),
    );
  }
}

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return AvailabilityRepository(ref.watch(driverApiClientProvider));
});

final availabilityProvider = FutureProvider.autoDispose.family<DriverAvailabilityResponseDto, DriverScope>(
  (ref, scope) => ref.watch(availabilityRepositoryProvider).fetch(scope),
);
