import 'package:noki_driver_app/core/api/driver_api_client.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/api/mfa/mfa_models.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';

/// Controllable [DriverApiClient] fake for tests, per DRIVER-APP-01 section
/// 33 (API testability): every method either returns a preset response or
/// throws a preset [AppFailure], set by the test before exercising the
/// repository/controller under test. No real HTTP call is ever made.
class FakeDriverApiClient implements DriverApiClient {
  /// Set for a plain, no-MFA login success - wrapped in [AuthLoginSuccess]
  /// by [login] below. Mutually exclusive with [loginMfaChallengeResponse];
  /// most existing tests only ever set this one.
  AuthTokensResponseDto? loginResponse;

  /// Set for a login that comes back as an MFA challenge (202) instead of
  /// tokens - wrapped in [AuthLoginMfaChallenge] by [login] below.
  AuthMfaChallengeResponseDto? loginMfaChallengeResponse;
  AppFailure? loginFailure;
  Duration? loginDelay;

  MfaEnrollmentStartResponseDto? mfaEnrollStartResponse;
  AppFailure? mfaEnrollStartFailure;
  String? lastMfaEnrollStartChallengeToken;
  int mfaEnrollStartCallCount = 0;

  MfaEnrollConfirmResponseDto? mfaEnrollConfirmResponse;
  AppFailure? mfaEnrollConfirmFailure;
  String? lastMfaEnrollConfirmCode;
  int mfaEnrollConfirmCallCount = 0;

  AuthTokensResponseDto? mfaVerifyResponse;
  AppFailure? mfaVerifyFailure;
  String? lastMfaVerifyCode;
  String? lastMfaVerifyRecoveryCode;
  int mfaVerifyCallCount = 0;

  int driverContextCallCount = 0;

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

  List<MobilityRideOfferDto>? listMobilityOffersResponse;
  Object? listMobilityOffersError;
  Duration? listMobilityOffersDelay;
  int listMobilityOffersCallCount = 0;

  MobilityRideDetailDto? currentMobilityRideResponse;
  AppFailure? currentMobilityRideFailure;

  List<MobilityRideDetailDto>? mobilityRideHistoryResponse;
  AppFailure? mobilityRideHistoryFailure;

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
  SubmitMobilityLocationDto? lastSubmitMobilityLocationRequest;

  SubmitDeliveryLocationResponseDto? submitDeliveryLocationResponse;
  AppFailure? submitDeliveryLocationFailure;
  SubmitDeliveryLocationDto? lastSubmitDeliveryLocationRequest;

  ComputeDriverRouteResponseDto? computeRouteResponse;
  AppFailure? computeRouteFailure;
  ComputeDriverRouteRequestDto? lastComputeRouteRequest;
  int computeRouteCallCount = 0;

  int loginCallCount = 0;
  int refreshCallCount = 0;

  @override
  Future<AuthLoginResult> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    if (loginDelay != null) await Future<void>.delayed(loginDelay!);
    if (loginFailure != null) throw loginFailure!;
    if (loginMfaChallengeResponse != null) {
      return AuthLoginMfaChallenge(loginMfaChallengeResponse!);
    }
    return AuthLoginSuccess(loginResponse!);
  }

  @override
  Future<MfaEnrollmentStartResponseDto> mfaEnrollStart({
    required String challengeToken,
  }) async {
    mfaEnrollStartCallCount++;
    lastMfaEnrollStartChallengeToken = challengeToken;
    if (mfaEnrollStartFailure != null) throw mfaEnrollStartFailure!;
    return mfaEnrollStartResponse!;
  }

  @override
  Future<MfaEnrollConfirmResponseDto> mfaEnrollConfirm({
    required String challengeToken,
    required String code,
  }) async {
    mfaEnrollConfirmCallCount++;
    lastMfaEnrollConfirmCode = code;
    if (mfaEnrollConfirmFailure != null) throw mfaEnrollConfirmFailure!;
    return mfaEnrollConfirmResponse!;
  }

  @override
  Future<AuthTokensResponseDto> mfaVerify({
    required String challengeToken,
    String? code,
    String? recoveryCode,
  }) async {
    mfaVerifyCallCount++;
    lastMfaVerifyCode = code;
    lastMfaVerifyRecoveryCode = recoveryCode;
    if (mfaVerifyFailure != null) throw mfaVerifyFailure!;
    return mfaVerifyResponse!;
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
  Future<AuthCapabilitiesResponseDto> capabilities() async =>
      capabilitiesResponse!;

  @override
  Future<DriverContextResponseDto> driverContext() async {
    driverContextCallCount++;
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

  int driverAvailabilityCallCount = 0;

  @override
  Future<DriverAvailabilityResponseDto> driverAvailability({
    required String organizationId,
    required String countryCode,
  }) async {
    driverAvailabilityCallCount++;
    if (availabilityFailure != null) throw availabilityFailure!;
    return availabilityResponse!;
  }

  @override
  Future<DriverAvailabilityResponseDto> updateDriverAvailability(
    UpdateDriverAvailabilityDto body,
  ) async {
    lastAvailabilityUpdate = body;
    if (availabilityFailure != null) throw availabilityFailure!;
    return availabilityResponse!;
  }

  int driverWorkFeedCallCount = 0;

  @override
  Future<DriverWorkFeedListResponseDto> driverWorkFeed({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) async {
    driverWorkFeedCallCount++;
    if (workFeedFailure != null) throw workFeedFailure!;
    return workFeedResponse!;
  }

  // --- Delivery (own-scoped) ---------------------------------------------

  int listOwnMissionsCallCount = 0;

  @override
  Future<DriverMissionListResponseDto> listOwnMissions({
    required String organizationId,
    required String countryCode,
    String? status,
    int page = 1,
    int pageSize = 25,
  }) async {
    listOwnMissionsCallCount++;
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
  Future<DeliveryHandoffOtpChallengeResponseDto> requestHandoffOtp(
    String missionId,
  ) async {
    if (requestHandoffOtpFailure != null) throw requestHandoffOtpFailure!;
    return requestHandoffOtpResponse!;
  }

  @override
  Future<DeliveryHandoffOtpVerificationResponseDto> verifyHandoffOtp(
    String missionId,
    VerifyDeliveryHandoffOtpDto body,
  ) async {
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
  Future<DeliveryIncidentResponseDto> createMissionIncident(
    String missionId,
    CreateDeliveryIncidentDto body,
  ) async {
    lastCreateMissionIncidentBody = body;
    if (createMissionIncidentFailure != null) {
      throw createMissionIncidentFailure!;
    }
    return createMissionIncidentResponse!;
  }

  @override
  Future<List<DeliveryIncidentResponseDto>> deliveryMissionIncidents(
    String missionId,
  ) async {
    if (deliveryMissionIncidentsFailure != null) {
      throw deliveryMissionIncidentsFailure!;
    }
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
  Future<List<MobilityRideOfferDto>> listMobilityOffers() async {
    listMobilityOffersCallCount++;
    if (listMobilityOffersDelay != null) {
      await Future<void>.delayed(listMobilityOffersDelay!);
    }
    if (listMobilityOffersError != null) throw listMobilityOffersError!;
    return listMobilityOffersResponse ?? const [];
  }

  int currentMobilityRideCallCount = 0;

  @override
  Future<MobilityRideDetailDto?> currentMobilityRide({
    required String organizationId,
    required String countryCode,
  }) async {
    currentMobilityRideCallCount++;
    if (currentMobilityRideFailure != null) throw currentMobilityRideFailure!;
    return currentMobilityRideResponse;
  }

  @override
  Future<List<MobilityRideDetailDto>> mobilityRideHistory({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) async {
    if (mobilityRideHistoryFailure != null) throw mobilityRideHistoryFailure!;
    return mobilityRideHistoryResponse ?? const [];
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
  Future<MobilityIncidentDto> createMobilityIncident(
    CreateOwnMobilityIncidentRequestDto body,
  ) async {
    lastCreateMobilityIncidentBody = body;
    if (createMobilityIncidentFailure != null) {
      throw createMobilityIncidentFailure!;
    }
    return createMobilityIncidentResponse!;
  }

  @override
  Future<MobilityRideDetailDto> acceptMobilityOffer(String offerId) async {
    lastAcceptedOfferId = offerId;
    if (acceptMobilityOfferFailure != null) throw acceptMobilityOfferFailure!;
    return acceptMobilityOfferResponse!;
  }

  @override
  Future<MobilityRideDetailDto> transitionMobilityRide(
    String rideId,
    TransitionMobilityRideDto body,
  ) async {
    lastTransitionMobilityRideBody = body;
    if (transitionMobilityRideFailure != null) {
      throw transitionMobilityRideFailure!;
    }
    return transitionMobilityRideResponse!;
  }

  @override
  Future<MobilityDriverDto> submitMobilityLocation(
    SubmitMobilityLocationDto body,
  ) async {
    lastSubmitMobilityLocationRequest = body;
    if (submitMobilityLocationFailure != null) {
      throw submitMobilityLocationFailure!;
    }
    return submitMobilityLocationResponse!;
  }

  @override
  Future<SubmitDeliveryLocationResponseDto> submitDeliveryLocation(
    SubmitDeliveryLocationDto body,
  ) async {
    lastSubmitDeliveryLocationRequest = body;
    if (submitDeliveryLocationFailure != null) {
      throw submitDeliveryLocationFailure!;
    }
    return submitDeliveryLocationResponse!;
  }

  // --- Navigation -----------------------------------------------------------

  @override
  Future<ComputeDriverRouteResponseDto> computeRoute(
    ComputeDriverRouteRequestDto body,
  ) async {
    computeRouteCallCount++;
    lastComputeRouteRequest = body;
    if (computeRouteFailure != null) throw computeRouteFailure!;
    return computeRouteResponse!;
  }
}
