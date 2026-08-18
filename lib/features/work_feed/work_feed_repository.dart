import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/driver_api_client.dart';
import '../../core/api/generated/driver_models.generated.dart';
import '../driver_context/driver_context_repository.dart';

class WorkFeedRepository {
  WorkFeedRepository(this._client);

  final DriverApiClient _client;

  /// Foundation-only: first page, default page size. Full pagination /
  /// mission workflow belongs to DRIVER-APP-03 (see README).
  Future<DriverWorkFeedListResponseDto> fetch(DriverScope scope) {
    return _client.driverWorkFeed(organizationId: scope.organizationId, countryCode: scope.countryCode);
  }
}

final workFeedRepositoryProvider = Provider<WorkFeedRepository>((ref) {
  return WorkFeedRepository(ref.watch(driverApiClientProvider));
});

final workFeedProvider = FutureProvider.autoDispose.family<DriverWorkFeedListResponseDto, DriverScope>(
  (ref, scope) => ref.watch(workFeedRepositoryProvider).fetch(scope),
);
