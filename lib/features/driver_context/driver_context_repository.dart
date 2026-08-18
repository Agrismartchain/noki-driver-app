import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/driver_api_client.dart';
import '../../core/api/generated/driver_models.generated.dart';

class DriverContextRepository {
  DriverContextRepository(this._client);

  final DriverApiClient _client;

  Future<DriverContextResponseDto> fetch() => _client.driverContext();
}

final driverContextRepositoryProvider = Provider<DriverContextRepository>((ref) {
  return DriverContextRepository(ref.watch(driverApiClientProvider));
});

/// Refetches the Driver context independently of the auth bootstrap copy
/// (`AuthState.driverContext`), so the Home screen can pull-to-refresh
/// without re-running the login/role-guard flow.
final driverContextProvider = FutureProvider.autoDispose<DriverContextResponseDto>((ref) {
  return ref.watch(driverContextRepositoryProvider).fetch();
});

/// The organization/country scope this phase operates in: the first Driver
/// profile on the context. Multi-organization/multi-country scope selection
/// is out of scope for DRIVER-APP-01 (see README limitations) - a driver
/// active in more than one organization sees only their first profile's
/// data until that selector ships.
class DriverScope {
  const DriverScope({required this.organizationId, required this.countryCode});

  final String organizationId;
  final String countryCode;

  @override
  bool operator ==(Object other) =>
      other is DriverScope && other.organizationId == organizationId && other.countryCode == countryCode;

  @override
  int get hashCode => Object.hash(organizationId, countryCode);
}

DriverScope? activeScopeFrom(DriverContextResponseDto context) {
  if (context.profiles.isEmpty) return null;
  final profile = context.profiles.first;
  return DriverScope(organizationId: profile.organizationId, countryCode: profile.countryCode);
}
