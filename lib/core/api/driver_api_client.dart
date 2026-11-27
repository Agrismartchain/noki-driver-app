import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../errors/app_failure.dart';
import 'finance/driver_finance_models.dart';
import 'generated/driver_models.generated.dart';
import 'mfa/mfa_models.dart';
import 'profile/driver_avatar_models.dart';

/// Thin, hand-written transport layer over the generated Dart models.
///
/// Every method here corresponds 1:1 to one whitelisted operationId in
/// `contract/lock.json` / `lib/core/api/generated/driver_operations.generated.dart`.
/// No URL is invented: paths are copied verbatim from the canonical OpenAPI
/// document. This class is an interface so tests and the repository layer
/// can substitute a fake without mocking Dio directly (see
/// `test/fixtures/fake_driver_api_client.dart`).
///
/// The MFA methods below (`mfaEnrollStart`/`mfaEnrollConfirm`/`mfaVerify`)
/// are the one exception to "every method maps to a whitelisted
/// operationId": see `core/api/mfa/mfa_models.dart`'s doc comment for why.
abstract class DriverApiClient {
  /// Either a full session ([AuthLoginSuccess]) or a pre-session MFA
  /// challenge ([AuthLoginMfaChallenge]) - `/v1/auth/login` returns 202 with
  /// no tokens at all for a privileged account that has not completed its
  /// second factor yet. Callers MUST switch on both cases (Dart's
  /// exhaustiveness check on the sealed [AuthLoginResult] enforces this) -
  /// never assume 200/[AuthTokensResponseDto].
  Future<AuthLoginResult> login({
    required String email,
    required String password,
  });
  Future<AuthTokensResponseDto> refresh({required String refreshToken});
  Future<LogoutResponseDto> logout();
  Future<MeResponseDto> me();
  Future<AuthCapabilitiesResponseDto> capabilities();

  // --- MFA (pre-session challenge flow) -----------------------------------

  /// Begins two-factor setup for an `ENROLL`-status challenge. The returned
  /// secret is shown exactly once - never persisted, never logged.
  Future<MfaEnrollmentStartResponseDto> mfaEnrollStart({
    required String challengeToken,
  });

  /// Confirms enrollment with the first authenticator code. On success the
  /// account now has an active second factor and a full session is issued
  /// in the same response, alongside one-time recovery codes.
  Future<MfaEnrollConfirmResponseDto> mfaEnrollConfirm({
    required String challengeToken,
    required String code,
  });

  /// Completes sign-in for a `VERIFY`-status challenge with either an
  /// authenticator code or a one-time recovery code.
  Future<AuthTokensResponseDto> mfaVerify({
    required String challengeToken,
    String? code,
    String? recoveryCode,
  });

  Future<DriverContextResponseDto> driverContext();
  Future<DriverVehicleListResponseDto> driverVehicles({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  });
  Future<DriverAvailabilityResponseDto> driverAvailability({
    required String organizationId,
    required String countryCode,
  });
  Future<DriverAvailabilityResponseDto> updateDriverAvailability(
    UpdateDriverAvailabilityDto body,
  );
  Future<DriverWorkFeedListResponseDto> driverWorkFeed({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  });

  // --- Delivery (own-scoped) ---------------------------------------------

  Future<DriverMissionListResponseDto> listOwnMissions({
    required String organizationId,
    required String countryCode,
    String? status,
    int page = 1,
    int pageSize = 25,
  });
  Future<DriverMissionResponseDto> getOwnMission(String missionId);
  Future<DeliveryHandoffOtpChallengeResponseDto> requestHandoffOtp(
    String missionId,
  );
  Future<DeliveryHandoffOtpVerificationResponseDto> verifyHandoffOtp(
    String missionId,
    VerifyDeliveryHandoffOtpDto body,
  );
  Future<DriverMissionCompletionResponseDto> completeMission(
    String missionId,
    CompleteDriverMissionDto body, {
    required String idempotencyKey,
  });
  Future<DeliveryIncidentResponseDto> createMissionIncident(
    String missionId,
    CreateDeliveryIncidentDto body,
  );
  Future<List<DeliveryIncidentResponseDto>> deliveryMissionIncidents(
    String missionId,
  );
  Future<DriverMissionResponseDto> scanMissionQr(ScanDeliveryQrDto body);
  Future<SubmitDeliveryLocationResponseDto> submitDeliveryLocation(
    SubmitDeliveryLocationDto body,
  );

  // --- Navigation -----------------------------------------------------------

  Future<ComputeDriverRouteResponseDto> computeRoute(
    ComputeDriverRouteRequestDto body,
  );

  // --- Mobility (own-scoped) ----------------------------------------------

  Future<DriverMobilityOfferListResponseDto> mobilityOffers({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  });
  Future<MobilityRideDetailDto?> currentMobilityRide({
    required String organizationId,
    required String countryCode,
  });
  Future<List<MobilityRideDetailDto>> mobilityRideHistory({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  });
  Future<MobilityRideDetailDto> mobilityRideById(String rideId);
  Future<DriverMobilityIncidentListResponseDto> mobilityIncidents({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  });
  Future<MobilityIncidentDto> createMobilityIncident(
    CreateOwnMobilityIncidentRequestDto body,
  );

  /// Bounded-polling discovery feed: the driver's currently pending
  /// (unexpired, unclaimed) Mobility ride offers, straight from
  /// `MobilityDriverController` - not the aggregation `DriverController`
  /// used by [mobilityOffers] above.
  Future<List<MobilityRideOfferDto>> listMobilityOffers();
  Future<MobilityRideDetailDto> acceptMobilityOffer(String offerId);
  Future<MobilityRideDetailDto> transitionMobilityRide(
    String rideId,
    TransitionMobilityRideDto body,
  );
  Future<MobilityDriverDto> submitMobilityLocation(
    SubmitMobilityLocationDto body,
  );

  // --- Driver Profile Avatar (own-scoped NOKI media storage) ---------------

  /// Cached `avatarUrl` extracted from the most recent `GET /v1/driver/context`
  /// response (or avatar update/remove mutation) without altering generated DTOs.
  String? get lastContextAvatarUrl;

  Future<DriverAvatarUploadIntentDto> createDriverAvatarUploadIntent({
    required String contentType,
    required int byteSizeExpected,
  });

  Future<void> uploadDriverAvatarBytes({
    required String uploadUrl,
    required Map<String, String> headers,
    required Uint8List bytes,
  });

  Future<DriverAvatarResponseDto> completeDriverAvatarUpload(String intentId);

  Future<DriverAvatarResponseDto> removeDriverAvatar();

  // --- Driver Finance & Wallet (own-scoped) --------------------------------

  Future<DriverFinanceSummaryDto> driverFinanceSummary({
    required String organizationId,
    required String countryCode,
  });

  Future<List<DriverEarningItemDto>> driverFinanceEarnings({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  });

  Future<List<DriverCodCollectionItemDto>> driverFinanceCod({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  });

  Future<DriverPayoutEligibilityDto> driverPayoutEligibility({
    required String organizationId,
    required String countryCode,
  });

  Future<List<DriverPayoutItemDto>> driverPayouts({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  });

  Future<DriverPayoutItemDto> requestDriverPayout({
    required String organizationId,
    required String countryCode,
    required String idempotencyKey,
    String? paymentMethodId,
    List<String>? obligationIds,
    String? requestedAmount,
  });

  Future<DriverPayoutItemDto> cancelDriverPayout({
    required String payoutId,
    required String organizationId,
    required String countryCode,
    required String reason,
    required String idempotencyKey,
  });
}

class DioDriverApiClient implements DriverApiClient {
  DioDriverApiClient(this._dio);

  final Dio _dio;

  Future<T> _guarded<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw AppFailure.fromDioException(e);
    }
  }

  @override
  Future<AuthLoginResult> login({
    required String email,
    required String password,
  }) => _guarded(() async {
    final response = await _dio.post(
      '/v1/auth/login',
      data: LoginRequestDto(email: email, password: password).toJson(),
    );
    final body = response.data as Map<String, dynamic>;
    // 202 Accepted: password step succeeded but a second factor is still
    // required - `body` is an `AuthMfaChallengeResponseDto`, not tokens.
    // This status-code check is the one thing standing between this client
    // and the original bug (deserializing every response as
    // `AuthTokensResponseDto` regardless of `mfaStatus`).
    if (response.statusCode == 202) {
      return AuthLoginMfaChallenge(AuthMfaChallengeResponseDto.fromJson(body));
    }
    return AuthLoginSuccess(AuthTokensResponseDto.fromJson(body));
  });

  @override
  Future<MfaEnrollmentStartResponseDto> mfaEnrollStart({
    required String challengeToken,
  }) => _guarded(() async {
    final response = await _dio.post(
      '/v1/auth/mfa/challenge/enroll/start',
      data: MfaChallengeEnrollStartRequestDto(
        challengeToken: challengeToken,
      ).toJson(),
    );
    return MfaEnrollmentStartResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<MfaEnrollConfirmResponseDto> mfaEnrollConfirm({
    required String challengeToken,
    required String code,
  }) => _guarded(() async {
    final response = await _dio.post(
      '/v1/auth/mfa/challenge/enroll/confirm',
      data: MfaChallengeEnrollConfirmRequestDto(
        challengeToken: challengeToken,
        code: code,
      ).toJson(),
    );
    return MfaEnrollConfirmResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<AuthTokensResponseDto> mfaVerify({
    required String challengeToken,
    String? code,
    String? recoveryCode,
  }) => _guarded(() async {
    final response = await _dio.post(
      '/v1/auth/mfa/challenge/verify',
      data: MfaChallengeVerifyRequestDto(
        challengeToken: challengeToken,
        code: code,
        recoveryCode: recoveryCode,
      ).toJson(),
    );
    return AuthTokensResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<AuthTokensResponseDto> refresh({required String refreshToken}) =>
      _guarded(() async {
        final response = await _dio.post(
          '/v1/auth/refresh',
          data: RefreshRequestDto(refreshToken: refreshToken).toJson(),
        );
        return AuthTokensResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      });

  @override
  Future<LogoutResponseDto> logout() => _guarded(() async {
    final response = await _dio.post('/v1/auth/logout');
    return LogoutResponseDto.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<MeResponseDto> me() => _guarded(() async {
    final response = await _dio.get('/v1/auth/me');
    return MeResponseDto.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<AuthCapabilitiesResponseDto> capabilities() => _guarded(() async {
    final response = await _dio.get('/v1/auth/capabilities');
    return AuthCapabilitiesResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<DriverContextResponseDto> driverContext() => _guarded(() async {
    final response = await _dio.get('/v1/driver/context');
    final body = response.data as Map<String, dynamic>;
    final rawAvatar = body['avatarUrl'] as String?;
    _lastContextAvatarUrl = _resolveMediaUrl(rawAvatar);
    return DriverContextResponseDto.fromJson(body);
  });

  @override
  Future<DriverVehicleListResponseDto> driverVehicles({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) => _guarded(() async {
    final response = await _dio.get(
      '/v1/driver/vehicles',
      queryParameters: {
        'organizationId': organizationId,
        'countryCode': countryCode,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return DriverVehicleListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<DriverAvailabilityResponseDto> driverAvailability({
    required String organizationId,
    required String countryCode,
  }) => _guarded(() async {
    final response = await _dio.get(
      '/v1/driver/availability',
      queryParameters: {
        'organizationId': organizationId,
        'countryCode': countryCode,
      },
    );
    return DriverAvailabilityResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<DriverAvailabilityResponseDto> updateDriverAvailability(
    UpdateDriverAvailabilityDto body,
  ) => _guarded(() async {
    final response = await _dio.patch(
      '/v1/driver/availability',
      data: body.toJson(),
    );
    return DriverAvailabilityResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<DriverWorkFeedListResponseDto> driverWorkFeed({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) => _guarded(() async {
    final response = await _dio.get(
      '/v1/driver/work-feed',
      queryParameters: {
        'organizationId': organizationId,
        'countryCode': countryCode,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return DriverWorkFeedListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  // --- Delivery (own-scoped) ---------------------------------------------

  @override
  Future<DriverMissionListResponseDto> listOwnMissions({
    required String organizationId,
    required String countryCode,
    String? status,
    int page = 1,
    int pageSize = 25,
  }) => _guarded(() async {
    final response = await _dio.get(
      '/v1/delivery/missions',
      queryParameters: {
        'organizationId': organizationId,
        'countryCode': countryCode,
        'status': ?status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return DriverMissionListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<DriverMissionResponseDto> getOwnMission(String missionId) =>
      _guarded(() async {
        final response = await _dio.get('/v1/delivery/missions/$missionId');
        return DriverMissionResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      });

  @override
  Future<DeliveryHandoffOtpChallengeResponseDto> requestHandoffOtp(
    String missionId,
  ) => _guarded(() async {
    final response = await _dio.post(
      '/v1/delivery/missions/$missionId/handoff-otp/request',
    );
    return DeliveryHandoffOtpChallengeResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<DeliveryHandoffOtpVerificationResponseDto> verifyHandoffOtp(
    String missionId,
    VerifyDeliveryHandoffOtpDto body,
  ) => _guarded(() async {
    final response = await _dio.post(
      '/v1/delivery/missions/$missionId/handoff-otp/verify',
      data: body.toJson(),
    );
    return DeliveryHandoffOtpVerificationResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<DriverMissionCompletionResponseDto> completeMission(
    String missionId,
    CompleteDriverMissionDto body, {
    required String idempotencyKey,
  }) => _guarded(() async {
    final response = await _dio.post(
      '/v1/delivery/missions/$missionId/complete',
      data: body.toJson(),
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return DriverMissionCompletionResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<DeliveryIncidentResponseDto> createMissionIncident(
    String missionId,
    CreateDeliveryIncidentDto body,
  ) => _guarded(() async {
    final response = await _dio.post(
      '/v1/delivery/missions/$missionId/incidents',
      data: body.toJson(),
    );
    return DeliveryIncidentResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<List<DeliveryIncidentResponseDto>> deliveryMissionIncidents(
    String missionId,
  ) => _guarded(() async {
    final response = await _dio.get(
      '/v1/driver/delivery/missions/$missionId/incidents',
    );
    return (response.data as List<dynamic>)
        .map(
          (e) =>
              DeliveryIncidentResponseDto.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  });

  @override
  Future<DriverMissionResponseDto> scanMissionQr(ScanDeliveryQrDto body) =>
      _guarded(() async {
        final response = await _dio.post(
          '/v1/delivery/missions/scan-qr',
          data: body.toJson(),
        );
        return DriverMissionResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      });

  @override
  Future<SubmitDeliveryLocationResponseDto> submitDeliveryLocation(
    SubmitDeliveryLocationDto body,
  ) => _guarded(() async {
    final response = await _dio.post(
      '/v1/delivery/location',
      data: body.toJson(),
    );
    return SubmitDeliveryLocationResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  // --- Navigation -----------------------------------------------------------

  @override
  Future<ComputeDriverRouteResponseDto> computeRoute(
    ComputeDriverRouteRequestDto body,
  ) => _guarded(() async {
    final response = await _dio.post(
      '/v1/driver/navigation/route',
      data: body.toJson(),
    );
    return ComputeDriverRouteResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  // --- Mobility (own-scoped) ----------------------------------------------

  @override
  Future<DriverMobilityOfferListResponseDto> mobilityOffers({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) => _guarded(() async {
    final response = await _dio.get(
      '/v1/driver/mobility/offers',
      queryParameters: {
        'organizationId': organizationId,
        'countryCode': countryCode,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return DriverMobilityOfferListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<MobilityRideDetailDto?> currentMobilityRide({
    required String organizationId,
    required String countryCode,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/driver/mobility/rides/current',
        queryParameters: {
          'organizationId': organizationId,
          'countryCode': countryCode,
        },
      );
      return MobilityRideDetailDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // No active ride is a normal, honest empty state, not a failure.
      if (e.response?.statusCode == 404) return null;
      throw AppFailure.fromDioException(e);
    }
  }

  @override
  Future<List<MobilityRideDetailDto>> mobilityRideHistory({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) => _guarded(() async {
    final response = await _dio.get(
      '/v1/driver/mobility/rides/history',
      queryParameters: {
        'organizationId': organizationId,
        'countryCode': countryCode,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final items =
        (response.data as Map<String, dynamic>)['items'] as List<dynamic>? ??
        const [];
    return items
        .map((e) => MobilityRideDetailDto.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  @override
  Future<MobilityRideDetailDto> mobilityRideById(String rideId) =>
      _guarded(() async {
        final response = await _dio.get('/v1/driver/mobility/rides/$rideId');
        return MobilityRideDetailDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      });

  @override
  Future<DriverMobilityIncidentListResponseDto> mobilityIncidents({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) => _guarded(() async {
    final response = await _dio.get(
      '/v1/driver/mobility/incidents',
      queryParameters: {
        'organizationId': organizationId,
        'countryCode': countryCode,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return DriverMobilityIncidentListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<MobilityIncidentDto> createMobilityIncident(
    CreateOwnMobilityIncidentRequestDto body,
  ) => _guarded(() async {
    final response = await _dio.post(
      '/v1/driver/mobility/incidents',
      data: body.toJson(),
    );
    return MobilityIncidentDto.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<List<MobilityRideOfferDto>> listMobilityOffers() => _guarded(() async {
    final response = await _dio.get('/v1/mobility/driver/offers');
    return (response.data as List<dynamic>)
        .map((e) => MobilityRideOfferDto.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  @override
  Future<MobilityRideDetailDto> acceptMobilityOffer(String offerId) =>
      _guarded(() async {
        final response = await _dio.post(
          '/v1/mobility/driver/offers/$offerId/accept',
        );
        return MobilityRideDetailDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      });

  @override
  Future<MobilityRideDetailDto> transitionMobilityRide(
    String rideId,
    TransitionMobilityRideDto body,
  ) => _guarded(() async {
    final response = await _dio.post(
      '/v1/mobility/driver/rides/$rideId/transition',
      data: body.toJson(),
    );
    return MobilityRideDetailDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<MobilityDriverDto> submitMobilityLocation(
    SubmitMobilityLocationDto body,
  ) => _guarded(() async {
    final response = await _dio.post(
      '/v1/mobility/driver/location',
      data: body.toJson(),
    );
    return MobilityDriverDto.fromJson(response.data as Map<String, dynamic>);
  });

  // --- Driver Profile Avatar -----------------------------------------------

  String? _lastContextAvatarUrl;

  @override
  String? get lastContextAvatarUrl => _lastContextAvatarUrl;

  String? _resolveMediaUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = _dio.options.baseUrl;
    if (base.isEmpty) return trimmed;
    return Uri.parse(base).resolve(trimmed).toString();
  }

  @override
  Future<DriverAvatarUploadIntentDto> createDriverAvatarUploadIntent({
    required String contentType,
    required int byteSizeExpected,
  }) => _guarded(() async {
    final response = await _dio.post(
      '/v1/driver/profile/avatar/upload-intent',
      data: {
        'contentType': contentType,
        'byteSizeExpected': byteSizeExpected,
      },
    );
    return DriverAvatarUploadIntentDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<void> uploadDriverAvatarBytes({
    required String uploadUrl,
    required Map<String, String> headers,
    required Uint8List bytes,
  }) => _guarded(() async {
    final resolved = _resolveMediaUrl(uploadUrl) ?? uploadUrl;
    final isExternalPresigned =
        uploadUrl.startsWith('http://') || uploadUrl.startsWith('https://');
    final client = isExternalPresigned ? Dio() : _dio;
    await client.put<void>(
      resolved,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          ...headers,
          Headers.contentLengthHeader: bytes.length,
        },
        contentType: headers['Content-Type'] ?? headers['content-type'],
      ),
    );
  });

  @override
  Future<DriverAvatarResponseDto> completeDriverAvatarUpload(String intentId) =>
      _guarded(() async {
        final response = await _dio.post(
          '/v1/driver/profile/avatar/upload-intent/$intentId/complete',
        );
        final dto = DriverAvatarResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
        final resolved = _resolveMediaUrl(dto.avatarUrl);
        _lastContextAvatarUrl = resolved;
        return DriverAvatarResponseDto(avatarUrl: resolved);
      });

  @override
  Future<DriverAvatarResponseDto> removeDriverAvatar() => _guarded(() async {
    final response = await _dio.delete('/v1/driver/profile/avatar');
    final dto = DriverAvatarResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
    _lastContextAvatarUrl = null;
    return dto;
  });

  // --- Driver Finance & Wallet ---------------------------------------------

  @override
  Future<DriverFinanceSummaryDto> driverFinanceSummary({
    required String organizationId,
    required String countryCode,
  }) => _guarded(() async {
    final response = await _dio.get(
      '/v1/driver/finance/summary',
      queryParameters: {
        'organizationId': organizationId,
        'countryCode': countryCode,
      },
    );
    return DriverFinanceSummaryDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<List<DriverEarningItemDto>> driverFinanceEarnings({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) => _guarded(() async {
    final response = await _dio.get(
      '/v1/driver/finance/earnings',
      queryParameters: {
        'organizationId': organizationId,
        'countryCode': countryCode,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final body = response.data as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(DriverEarningItemDto.fromJson)
        .toList(growable: false);
  });

  @override
  Future<List<DriverCodCollectionItemDto>> driverFinanceCod({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) => _guarded(() async {
    final response = await _dio.get(
      '/v1/driver/finance/cod',
      queryParameters: {
        'organizationId': organizationId,
        'countryCode': countryCode,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final body = response.data as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(DriverCodCollectionItemDto.fromJson)
        .toList(growable: false);
  });

  @override
  Future<DriverPayoutEligibilityDto> driverPayoutEligibility({
    required String organizationId,
    required String countryCode,
  }) => _guarded(() async {
    final response = await _dio.get(
      '/v1/driver/finance/payouts/eligibility',
      queryParameters: {
        'organizationId': organizationId,
        'countryCode': countryCode,
      },
    );
    return DriverPayoutEligibilityDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  });

  @override
  Future<List<DriverPayoutItemDto>> driverPayouts({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) => _guarded(() async {
    final response = await _dio.get(
      '/v1/driver/finance/payouts',
      queryParameters: {
        'organizationId': organizationId,
        'countryCode': countryCode,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final body = response.data as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(DriverPayoutItemDto.fromJson)
        .toList(growable: false);
  });

  @override
  Future<DriverPayoutItemDto> requestDriverPayout({
    required String organizationId,
    required String countryCode,
    required String idempotencyKey,
    String? paymentMethodId,
    List<String>? obligationIds,
    String? requestedAmount,
  }) => _guarded(() async {
    final response = await _dio.post(
      '/v1/driver/finance/payouts',
      data: {
        'organizationId': organizationId,
        'countryCode': countryCode,
        if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
        if (obligationIds != null && obligationIds.isNotEmpty)
          'obligationIds': obligationIds,
        if (requestedAmount != null) 'requestedAmount': requestedAmount,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return DriverPayoutItemDto.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<DriverPayoutItemDto> cancelDriverPayout({
    required String payoutId,
    required String organizationId,
    required String countryCode,
    required String reason,
    required String idempotencyKey,
  }) => _guarded(() async {
    final response = await _dio.post(
      '/v1/driver/finance/payouts/$payoutId/cancel',
      data: {
        'organizationId': organizationId,
        'countryCode': countryCode,
        'reason': reason,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return DriverPayoutItemDto.fromJson(response.data as Map<String, dynamic>);
  });
}
