import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/driver_api_client.dart';
import '../../core/api/generated/driver_models.generated.dart';
import '../driver_context/driver_context_repository.dart';

/// Own-scoped Delivery mission access, backed by `/v1/delivery/missions/*`
/// (the driver-owned subset of `DeliveryController`, not the ops-facing
/// `/v1/delivery/shipments/*` surface). Every mutation here is exactly one
/// of the driver-legal actions confirmed by the DRIVER-APP-02 contract
/// audit: request/verify handoff OTP, complete (the only status-mutating
/// transition a driver can perform - there is no accept/pickup/arrive
/// endpoint), report an incident, and scan a QR token. No status transition
/// is invented beyond what these endpoints actually perform server-side.
class DeliveryRepository {
  DeliveryRepository(this._client);

  final DriverApiClient _client;

  Future<DriverMissionListResponseDto> listMissions(DriverScope scope, {String? status}) {
    return _client.listOwnMissions(organizationId: scope.organizationId, countryCode: scope.countryCode, status: status);
  }

  Future<DriverMissionResponseDto> getMission(String missionId) => _client.getOwnMission(missionId);

  Future<DeliveryHandoffOtpChallengeResponseDto> requestOtp(String missionId) => _client.requestHandoffOtp(missionId);

  Future<DeliveryHandoffOtpVerificationResponseDto> verifyOtp(String missionId, {required String challengeId, required String code}) {
    return _client.verifyHandoffOtp(missionId, VerifyDeliveryHandoffOtpDto(challengeId: challengeId, code: code));
  }

  Future<DriverMissionCompletionResponseDto> complete(
    String missionId, {
    required String otpChallengeId,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    required String idempotencyKey,
  }) {
    return _client.completeMission(
      missionId,
      CompleteDriverMissionDto(otpChallengeId: otpChallengeId, latitude: latitude, longitude: longitude, accuracyMeters: accuracyMeters),
      idempotencyKey: idempotencyKey,
    );
  }

  Future<DeliveryIncidentResponseDto> createIncident(
    String missionId, {
    required CreateDeliveryIncidentDtoType type,
    String? comment,
  }) {
    return _client.createMissionIncident(missionId, CreateDeliveryIncidentDto(type: type, comment: comment));
  }

  Future<List<DeliveryIncidentResponseDto>> listIncidents(String missionId) => _client.deliveryMissionIncidents(missionId);

  Future<DriverMissionResponseDto> scanQr(String token) => _client.scanMissionQr(ScanDeliveryQrDto(token: token));
}

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository(ref.watch(driverApiClientProvider));
});

final missionListProvider = FutureProvider.autoDispose.family<DriverMissionListResponseDto, DriverScope>(
  (ref, scope) => ref.watch(deliveryRepositoryProvider).listMissions(scope),
);

final missionDetailProvider = FutureProvider.autoDispose.family<DriverMissionResponseDto, String>(
  (ref, missionId) => ref.watch(deliveryRepositoryProvider).getMission(missionId),
);

final missionIncidentsProvider = FutureProvider.autoDispose.family<List<DeliveryIncidentResponseDto>, String>(
  (ref, missionId) => ref.watch(deliveryRepositoryProvider).listIncidents(missionId),
);

/// Missions filtered by status - used by Home's "continue active delivery"
/// card and by [DeliveryHistoryScreen] (`status: DELIVERED`). Keyed by a
/// record (Dart 3 records have structural equality, so this works directly
/// as a Riverpod `family` argument without a bespoke key class).
final missionListByStatusProvider = FutureProvider.autoDispose.family<DriverMissionListResponseDto, (DriverScope, String)>(
  (ref, args) => ref.watch(deliveryRepositoryProvider).listMissions(args.$1, status: args.$2),
);
