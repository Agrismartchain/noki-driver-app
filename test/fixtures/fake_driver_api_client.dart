import 'package:noki_driver_app/core/api/driver_api_client.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';

/// Controllable [DriverApiClient] fake for tests, per DRIVER-APP-01 section
/// 33 (API testability): every method either returns a preset response or
/// throws a preset [AppFailure], set by the test before exercising the
/// repository/controller under test. No real HTTP call is ever made.
class FakeDriverApiClient implements DriverApiClient {
  AuthTokensResponseDto? loginResponse;
  AppFailure? loginFailure;
  Duration? loginDelay;

  AuthTokensResponseDto? refreshResponse;
  AppFailure? refreshFailure;

  LogoutResponseDto logoutResponse = const LogoutResponseDto(revoked: true);

  MeResponseDto? meResponse;
  AuthCapabilitiesResponseDto? capabilitiesResponse;

  DriverContextResponseDto? driverContextResponse;
  AppFailure? driverContextFailure;

  DriverVehicleListResponseDto? vehiclesResponse;
  AppFailure? vehiclesFailure;

  DriverAvailabilityResponseDto? availabilityResponse;
  AppFailure? availabilityFailure;
  UpdateDriverAvailabilityDto? lastAvailabilityUpdate;

  DriverWorkFeedListResponseDto? workFeedResponse;
  AppFailure? workFeedFailure;

  // --- Delivery (own-scoped) ---------------------------------------------

  DriverMissionListResponseDto? listOwnMissionsResponse;
  AppFailure? listOwnMissionsFailure;

  DriverMissionResponseDto? getOwnMissionResponse;
  AppFailure? getOwnMissionFailure;
  String? lastGetOwnMissionId;

  DeliveryHandoffOtpChallengeResponseDto? requestHandoffOtpResponse;
  AppFailure? requestHandoffOtpFailure;

  DeliveryHandoffOtpVerificationResponseDto? verifyHandoffOtpResponse;
  AppFailure? verifyHandoffOtpFailure;
  VerifyDeliveryHandoffOtpDto? lastVerifyHandoffOtpBody;

  DriverMissionCompletionResponseDto? completeMissionResponse;
  AppFailure? completeMissionFailure;
  CompleteDriverMissionDto? lastCompleteMissionBody;
  String? lastCompleteMissionIdempotencyKey;
  int completeMissionCallCount = 0;

  DeliveryIncidentResponseDto? createMissionIncidentResponse;
  AppFailure? createMissionIncidentFailure;
  CreateDeliveryIncidentDto? lastCreateMissionIncidentBody;

  List<DeliveryIncidentResponseDto>? deliveryMissionIncidentsResponse;
  AppFailure? deliveryMissionIncidentsFailure;

  DriverMissionResponseDto? scanMissionQrResponse;
  AppFailure? scanMissionQrFailure;

  // --- Mobility (own-scoped) ----------------------------------------------

  DriverMobilityOfferListResponseDto? mobilityOffersResponse;
  AppFailure? mobilityOffersFailure;

  MobilityRideDetailDto? currentMobilityRideResponse;
  AppFailure? currentMobilityRideFailure;

  MobilityRideDetailDto? mobilityRideByIdResponse;
  AppFailure? mobilityRideByIdFailure;

  DriverMobilityIncidentListResponseDto? mobilityIncidentsResponse;
  AppFailure? mobilityIncidentsFailure;

  MobilityIncidentDto? createMobilityIncidentResponse;
  AppFailure? createMobilityIncidentFailure;
  CreateOwnMobilityIncidentRequestDto? lastCreateMobilityIncidentBody;

  MobilityRideDetailDto? acceptMobilityOfferResponse;
  AppFailure? acceptMobilityOfferFailure;
  String? lastAcceptedOfferId;

  MobilityRideDetailDto? transitionMobilityRideResponse;
  AppFailure? transitionMobilityRideFailure;
  TransitionMobilityRideDto? lastTransitionMobilityRideBody;

  MobilityDriverDto? submitMobilityLocationResponse;
  AppFailure? submitMobilityLocationFailure;

  int loginCallCount = 0;
  int refreshCallCount = 0;

  @override
  Future<AuthTokensResponseDto> login({required String email, required String password}) async {
    loginCallCount++;
    if (loginDelay != null) await Future<void>.delayed(loginDelay!);
    if (loginFailure != null) throw loginFailure!;
    return loginResponse!;
  }

  @override
  Future<AuthTokensResponseDto> refresh({required String refreshToken}) async {
    refreshCallCount++;
    if (refreshFailure != null) throw refreshFailure!;
    return refreshResponse!;
  }

  @override
  Future<LogoutResponseDto> logout() async => logoutResponse;

  @override
  Future<MeResponseDto> me() async => meResponse!;

  @override
  Future<AuthCapabilitiesResponseDto> capabilities() async => capabilitiesResponse!;

  @override
  Future<DriverContextResponseDto> driverContext() async {
    if (driverContextFailure != null) throw driverContextFailure!;
    return driverContextResponse!;
  }

  @override
  Future<DriverVehicleListResponseDto> driverVehicles({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) async {
    if (vehiclesFailure != null) throw vehiclesFailure!;
    return vehiclesResponse!;
  }

  @override
  Future<DriverAvailabilityResponseDto> driverAvailability({
    required String organizationId,
    required String countryCode,
  }) async {
    if (availabilityFailure != null) throw availabilityFailure!;
    return availabilityResponse!;
  }

  @override
  Future<DriverAvailabilityResponseDto> updateDriverAvailability(UpdateDriverAvailabilityDto body) async {
    lastAvailabilityUpdate = body;
    if (availabilityFailure != null) throw availabilityFailure!;
    return availabilityResponse!;
  }

  @override
  Future<DriverWorkFeedListResponseDto> driverWorkFeed({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) async {
    if (workFeedFailure != null) throw workFeedFailure!;
    return workFeedResponse!;
  }

  // --- Delivery (own-scoped) ---------------------------------------------

  @override
  Future<DriverMissionListResponseDto> listOwnMissions({
    required String organizationId,
    required String countryCode,
    String? status,
    int page = 1,
    int pageSize = 25,
  }) async {
    if (listOwnMissionsFailure != null) throw listOwnMissionsFailure!;
    return listOwnMissionsResponse!;
  }

  @override
  Future<DriverMissionResponseDto> getOwnMission(String missionId) async {
    lastGetOwnMissionId = missionId;
    if (getOwnMissionFailure != null) throw getOwnMissionFailure!;
    return getOwnMissionResponse!;
  }

  @override
  Future<DeliveryHandoffOtpChallengeResponseDto> requestHandoffOtp(String missionId) async {
    if (requestHandoffOtpFailure != null) throw requestHandoffOtpFailure!;
    return requestHandoffOtpResponse!;
  }

  @override
  Future<DeliveryHandoffOtpVerificationResponseDto> verifyHandoffOtp(String missionId, VerifyDeliveryHandoffOtpDto body) async {
    lastVerifyHandoffOtpBody = body;
    if (verifyHandoffOtpFailure != null) throw verifyHandoffOtpFailure!;
    return verifyHandoffOtpResponse!;
  }

  @override
  Future<DriverMissionCompletionResponseDto> completeMission(
    String missionId,
    CompleteDriverMissionDto body, {
    required String idempotencyKey,
  }) async {
    completeMissionCallCount++;
    lastCompleteMissionBody = body;
    lastCompleteMissionIdempotencyKey = idempotencyKey;
    if (completeMissionFailure != null) throw completeMissionFailure!;
    return completeMissionResponse!;
  }

  @override
  Future<DeliveryIncidentResponseDto> createMissionIncident(String missionId, CreateDeliveryIncidentDto body) async {
    lastCreateMissionIncidentBody = body;
    if (createMissionIncidentFailure != null) throw createMissionIncidentFailure!;
    return createMissionIncidentResponse!;
  }

  @override
  Future<List<DeliveryIncidentResponseDto>> deliveryMissionIncidents(String missionId) async {
    if (deliveryMissionIncidentsFailure != null) throw deliveryMissionIncidentsFailure!;
    return deliveryMissionIncidentsResponse!;
  }

  @override
  Future<DriverMissionResponseDto> scanMissionQr(ScanDeliveryQrDto body) async {
    if (scanMissionQrFailure != null) throw scanMissionQrFailure!;
    return scanMissionQrResponse!;
  }

  // --- Mobility (own-scoped) ----------------------------------------------

  @override
  Future<DriverMobilityOfferListResponseDto> mobilityOffers({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) async {
    if (mobilityOffersFailure != null) throw mobilityOffersFailure!;
    return mobilityOffersResponse!;
  }

  @override
  Future<MobilityRideDetailDto?> currentMobilityRide({
    required String organizationId,
    required String countryCode,
  }) async {
    if (currentMobilityRideFailure != null) throw currentMobilityRideFailure!;
    return currentMobilityRideResponse;
  }

  @override
  Future<MobilityRideDetailDto> mobilityRideById(String rideId) async {
    if (mobilityRideByIdFailure != null) throw mobilityRideByIdFailure!;
    return mobilityRideByIdResponse!;
  }

  @override
  Future<DriverMobilityIncidentListResponseDto> mobilityIncidents({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) async {
    if (mobilityIncidentsFailure != null) throw mobilityIncidentsFailure!;
    return mobilityIncidentsResponse!;
  }

  @override
  Future<MobilityIncidentDto> createMobilityIncident(CreateOwnMobilityIncidentRequestDto body) async {
    lastCreateMobilityIncidentBody = body;
    if (createMobilityIncidentFailure != null) throw createMobilityIncidentFailure!;
    return createMobilityIncidentResponse!;
  }

  @override
  Future<MobilityRideDetailDto> acceptMobilityOffer(String offerId) async {
    lastAcceptedOfferId = offerId;
    if (acceptMobilityOfferFailure != null) throw acceptMobilityOfferFailure!;
    return acceptMobilityOfferResponse!;
  }

  @override
  Future<MobilityRideDetailDto> transitionMobilityRide(String rideId, TransitionMobilityRideDto body) async {
    lastTransitionMobilityRideBody = body;
    if (transitionMobilityRideFailure != null) throw transitionMobilityRideFailure!;
    return transitionMobilityRideResponse!;
  }

  @override
  Future<MobilityDriverDto> submitMobilityLocation(SubmitMobilityLocationDto body) async {
    if (submitMobilityLocationFailure != null) throw submitMobilityLocationFailure!;
    return submitMobilityLocationResponse!;
  }
}
