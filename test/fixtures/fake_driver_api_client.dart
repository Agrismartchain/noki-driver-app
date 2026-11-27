import 'dart:typed_data';

import 'package:noki_driver_app/core/api/driver_api_client.dart';
import 'package:noki_driver_app/core/api/finance/driver_finance_models.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/api/mfa/mfa_models.dart';
import 'package:noki_driver_app/core/api/profile/driver_avatar_models.dart';
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

  // --- Driver Profile Avatar -----------------------------------------------

  String? driverAvatarUrl;
  DriverAvatarUploadIntentDto? createAvatarIntentResponse;
  AppFailure? createAvatarIntentFailure;
  AppFailure? uploadAvatarBytesFailure;
  DriverAvatarResponseDto? completeAvatarUploadResponse;
  AppFailure? completeAvatarUploadFailure;
  DriverAvatarResponseDto? removeAvatarResponse;
  AppFailure? removeAvatarFailure;
  int uploadAvatarBytesCallCount = 0;
  int completeAvatarUploadCallCount = 0;
  int removeAvatarCallCount = 0;
  Uint8List? lastUploadedAvatarBytes;

  @override
  String? get lastContextAvatarUrl => driverAvatarUrl;

  @override
  Future<DriverAvatarUploadIntentDto> createDriverAvatarUploadIntent({
    required String contentType,
    required int byteSizeExpected,
  }) async {
    if (createAvatarIntentFailure != null) throw createAvatarIntentFailure!;
    return createAvatarIntentResponse ??
        DriverAvatarUploadIntentDto(
          intentId: 'intent-1',
          objectKey: 'driver-avatars/actor-1/avatar.png',
          uploadUrl: '/v1/_internal/object-storage/local/avatar.png',
          uploadMethod: 'PUT',
          uploadHeaders: {'Content-Type': contentType},
          expiresAt: '2026-12-01T00:00:00Z',
        );
  }

  @override
  Future<void> uploadDriverAvatarBytes({
    required String uploadUrl,
    required Map<String, String> headers,
    required Uint8List bytes,
  }) async {
    uploadAvatarBytesCallCount++;
    lastUploadedAvatarBytes = bytes;
    if (uploadAvatarBytesFailure != null) throw uploadAvatarBytesFailure!;
  }

  @override
  Future<DriverAvatarResponseDto> completeDriverAvatarUpload(
    String intentId,
  ) async {
    completeAvatarUploadCallCount++;
    if (completeAvatarUploadFailure != null) {
      throw completeAvatarUploadFailure!;
    }
    final dto =
        completeAvatarUploadResponse ??
        const DriverAvatarResponseDto(
          avatarUrl: 'https://cdn.noki-services.com/avatars/driver-1.png',
        );
    driverAvatarUrl = dto.avatarUrl;
    return dto;
  }

  @override
  Future<DriverAvatarResponseDto> removeDriverAvatar() async {
    removeAvatarCallCount++;
    if (removeAvatarFailure != null) throw removeAvatarFailure!;
    driverAvatarUrl = null;
    return removeAvatarResponse ?? const DriverAvatarResponseDto(avatarUrl: null);
  }

  // --- Driver Finance & Wallet ---------------------------------------------

  DriverFinanceSummaryDto? driverFinanceSummaryResponse;
  AppFailure? driverFinanceSummaryFailure;

  List<DriverEarningItemDto>? driverFinanceEarningsResponse;
  AppFailure? driverFinanceEarningsFailure;

  List<DriverCodCollectionItemDto>? driverFinanceCodResponse;
  AppFailure? driverFinanceCodFailure;

  DriverPayoutEligibilityDto? driverPayoutEligibilityResponse;
  AppFailure? driverPayoutEligibilityFailure;

  List<DriverPayoutItemDto>? driverPayoutsResponse;
  AppFailure? driverPayoutsFailure;

  DriverPayoutItemDto? requestDriverPayoutResponse;
  AppFailure? requestDriverPayoutFailure;
  int requestDriverPayoutCallCount = 0;
  String? lastRequestDriverPayoutIdempotencyKey;
  String? lastRequestDriverPayoutAmount;

  DriverPayoutItemDto? cancelDriverPayoutResponse;
  AppFailure? cancelDriverPayoutFailure;
  int cancelDriverPayoutCallCount = 0;

  @override
  Future<DriverFinanceSummaryDto> driverFinanceSummary({
    required String organizationId,
    required String countryCode,
  }) async {
    if (driverFinanceSummaryFailure != null) {
      throw driverFinanceSummaryFailure!;
    }
    return driverFinanceSummaryResponse ??
        DriverFinanceSummaryDto(
          driverActorId: 'driver-1',
          organizationId: organizationId,
          countryCode: countryCode,
          currencyCode: 'XAF',
          availableAmount: '0',
          pendingPayoutAmount: '0',
          paidAmount: '0',
          onHoldAmount: '0',
          grossEarnedAmount: '0',
          receivableCommissionAmount: '0',
          paymentMethodStatus: 'NONE',
          canRequestPayout: false,
          missingRemunerationRuleServices: const [],
          codSummary: const DriverCodSummaryDto(
            currencyCode: 'XAF',
            toRemitAmount: '0',
            remittedAmount: '0',
            reconciledAmount: '0',
            toRemitCount: 0,
            totalDeclaredCount: 0,
          ),
          generatedAt: '2026-11-27T10:00:00Z',
        );
  }

  @override
  Future<List<DriverEarningItemDto>> driverFinanceEarnings({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) async {
    if (driverFinanceEarningsFailure != null) {
      throw driverFinanceEarningsFailure!;
    }
    return driverFinanceEarningsResponse ?? const [];
  }

  @override
  Future<List<DriverCodCollectionItemDto>> driverFinanceCod({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) async {
    if (driverFinanceCodFailure != null) throw driverFinanceCodFailure!;
    return driverFinanceCodResponse ?? const [];
  }

  @override
  Future<DriverPayoutEligibilityDto> driverPayoutEligibility({
    required String organizationId,
    required String countryCode,
  }) async {
    if (driverPayoutEligibilityFailure != null) {
      throw driverPayoutEligibilityFailure!;
    }
    return driverPayoutEligibilityResponse ??
        const DriverPayoutEligibilityDto(
          eligible: false,
          currencyCode: 'XAF',
          availableAmount: '0',
          eligibleObligationIds: [],
          blockers: [],
        );
  }

  @override
  Future<List<DriverPayoutItemDto>> driverPayouts({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) async {
    if (driverPayoutsFailure != null) throw driverPayoutsFailure!;
    return driverPayoutsResponse ?? const [];
  }

  @override
  Future<DriverPayoutItemDto> requestDriverPayout({
    required String organizationId,
    required String countryCode,
    required String idempotencyKey,
    String? paymentMethodId,
    List<String>? obligationIds,
    String? requestedAmount,
  }) async {
    requestDriverPayoutCallCount++;
    lastRequestDriverPayoutIdempotencyKey = idempotencyKey;
    lastRequestDriverPayoutAmount = requestedAmount;
    if (requestDriverPayoutFailure != null) throw requestDriverPayoutFailure!;
    return requestDriverPayoutResponse ??
        const DriverPayoutItemDto(
          id: 'payout-1',
          code: 'P2-TEST001',
          status: 'PENDING_FIRST_APPROVAL',
          currencyCode: 'XAF',
          totalAmount: '8500',
          destinationMasked: '+242 05***88',
          paymentMethodType: 'MOBILE_MONEY',
          lineCount: 1,
          createdAt: '2026-11-27T10:00:00Z',
        );
  }

  @override
  Future<DriverPayoutItemDto> cancelDriverPayout({
    required String payoutId,
    required String organizationId,
    required String countryCode,
    required String reason,
    required String idempotencyKey,
  }) async {
    cancelDriverPayoutCallCount++;
    if (cancelDriverPayoutFailure != null) throw cancelDriverPayoutFailure!;
    return cancelDriverPayoutResponse ??
        DriverPayoutItemDto(
          id: payoutId,
          code: 'P2-TEST001',
          status: 'CANCELLED',
          currencyCode: 'XAF',
          totalAmount: '8500',
          destinationMasked: '+242 05***88',
          paymentMethodType: 'MOBILE_MONEY',
          lineCount: 1,
          createdAt: '2026-11-27T10:00:00Z',
          cancelledAt: '2026-11-27T10:05:00Z',
        );
  }
}
