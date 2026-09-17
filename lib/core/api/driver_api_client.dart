import 'package:dio/dio.dart';

import '../errors/app_failure.dart';
import 'generated/driver_models.generated.dart';

/// Thin, hand-written transport layer over the generated Dart models.
///
/// Every method here corresponds 1:1 to one whitelisted operationId in
/// `contract/lock.json` / `lib/core/api/generated/driver_operations.generated.dart`.
/// No URL is invented: paths are copied verbatim from the canonical OpenAPI
/// document. This class is an interface so tests and the repository layer
/// can substitute a fake without mocking Dio directly (see
/// `test/fixtures/fake_driver_api_client.dart`).
abstract class DriverApiClient {
  Future<AuthTokensResponseDto> login({
    required String email,
    required String password,
  });
  Future<AuthTokensResponseDto> refresh({required String refreshToken});
  Future<LogoutResponseDto> logout();
  Future<MeResponseDto> me();
  Future<AuthCapabilitiesResponseDto> capabilities();

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
  Future<AuthTokensResponseDto> login({
    required String email,
    required String password,
  }) => _guarded(() async {
    final response = await _dio.post(
      '/v1/auth/login',
      data: LoginRequestDto(email: email, password: password).toJson(),
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
    return DriverContextResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
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
}
