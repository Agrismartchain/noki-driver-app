import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/driver_api_client.dart';
import '../../core/api/generated/driver_models.generated.dart';
import '../driver_context/driver_context_repository.dart';

/// Own-scoped Mobility access. Offer/ride reads go through the aggregation
/// `DriverController` (`/v1/driver/mobility/*` - no separate GET-by-id for
/// an offer exists, so an offer detail screen must be handed the
/// `DriverMobilityOfferDto` it already has from the list, not re-fetch it),
/// while offer accept and ride transitions go through the real
/// `MobilityController` driver-owned mutations
/// (`/v1/mobility/driver/offers/:id/accept`,
/// `/v1/mobility/driver/rides/:id/transition`) - the only two Mobility
/// mutations a driver can perform.
class MobilityRepository {
  MobilityRepository(this._client);

  final DriverApiClient _client;

  Future<DriverMobilityOfferListResponseDto> offers(DriverScope scope) {
    return _client.mobilityOffers(
      organizationId: scope.organizationId,
      countryCode: scope.countryCode,
    );
  }

  Future<MobilityRideDetailDto?> currentRide(DriverScope scope) {
    return _client.currentMobilityRide(
      organizationId: scope.organizationId,
      countryCode: scope.countryCode,
    );
  }

  Future<List<MobilityRideDetailDto>> history(DriverScope scope) {
    return _client.mobilityRideHistory(
      organizationId: scope.organizationId,
      countryCode: scope.countryCode,
    );
  }

  Future<MobilityRideDetailDto> rideById(String rideId) =>
      _client.mobilityRideById(rideId);

  Future<DriverMobilityIncidentListResponseDto> incidents(DriverScope scope) {
    return _client.mobilityIncidents(
      organizationId: scope.organizationId,
      countryCode: scope.countryCode,
    );
  }

  Future<MobilityIncidentDto> createIncident(
    DriverScope scope, {
    String? rideId,
    required CreateOwnMobilityIncidentRequestDtoType type,
    String? comment,
  }) {
    return _client.createMobilityIncident(
      CreateOwnMobilityIncidentRequestDto(
        rideId: rideId,
        type: type,
        comment: comment,
        organizationId: scope.organizationId,
        countryCode: scope.countryCode,
      ),
    );
  }

  /// Lean, purpose-built discovery feed for bounded polling (see
  /// [MobilityOfferPollerController]) - distinct from [offers] above, which
  /// hits the aggregation `DriverController` and returns paginated results
  /// mixed in with other own-scoped Mobility reads.
  Future<List<MobilityRideOfferDto>> pollPendingOffers() =>
      _client.listMobilityOffers();

  Future<MobilityRideDetailDto> acceptOffer(String offerId) =>
      _client.acceptMobilityOffer(offerId);

  Future<MobilityRideDetailDto> transitionRide(
    String rideId,
    TransitionMobilityRideDtoStatus status,
  ) {
    return _client.transitionMobilityRide(
      rideId,
      TransitionMobilityRideDto(status: status),
    );
  }
}

final mobilityRepositoryProvider = Provider<MobilityRepository>((ref) {
  return MobilityRepository(ref.watch(driverApiClientProvider));
});

final mobilityOffersProvider = FutureProvider.autoDispose
    .family<DriverMobilityOfferListResponseDto, DriverScope>(
      (ref, scope) => ref.watch(mobilityRepositoryProvider).offers(scope),
    );

final currentRideProvider = FutureProvider.autoDispose
    .family<MobilityRideDetailDto?, DriverScope>(
      (ref, scope) => ref.watch(mobilityRepositoryProvider).currentRide(scope),
    );

final mobilityRideHistoryProvider = FutureProvider.autoDispose
    .family<List<MobilityRideDetailDto>, DriverScope>(
      (ref, scope) => ref.watch(mobilityRepositoryProvider).history(scope),
    );

final rideByIdProvider = FutureProvider.autoDispose
    .family<MobilityRideDetailDto, String>(
      (ref, rideId) => ref.watch(mobilityRepositoryProvider).rideById(rideId),
    );

final mobilityIncidentsProvider = FutureProvider.autoDispose
    .family<DriverMobilityIncidentListResponseDto, DriverScope>(
      (ref, scope) => ref.watch(mobilityRepositoryProvider).incidents(scope),
    );
