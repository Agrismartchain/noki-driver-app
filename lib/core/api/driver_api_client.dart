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
  Future<AuthTokensResponseDto> login({required String email, required String password});
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
  Future<DriverAvailabilityResponseDto> updateDriverAvailability(UpdateDriverAvailabilityDto body);
  Future<DriverWorkFeedListResponseDto> driverWorkFeed({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
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
  Future<AuthTokensResponseDto> login({required String email, required String password}) => _guarded(() async {
        final response = await _dio.post(
          '/v1/auth/login',
          data: LoginRequestDto(email: email, password: password).toJson(),
        );
        return AuthTokensResponseDto.fromJson(response.data as Map<String, dynamic>);
      });

  @override
  Future<AuthTokensResponseDto> refresh({required String refreshToken}) => _guarded(() async {
        final response = await _dio.post(
          '/v1/auth/refresh',
          data: RefreshRequestDto(refreshToken: refreshToken).toJson(),
        );
        return AuthTokensResponseDto.fromJson(response.data as Map<String, dynamic>);
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
        return AuthCapabilitiesResponseDto.fromJson(response.data as Map<String, dynamic>);
      });

  @override
  Future<DriverContextResponseDto> driverContext() => _guarded(() async {
        final response = await _dio.get('/v1/driver/context');
        return DriverContextResponseDto.fromJson(response.data as Map<String, dynamic>);
      });

  @override
  Future<DriverVehicleListResponseDto> driverVehicles({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) =>
      _guarded(() async {
        final response = await _dio.get(
          '/v1/driver/vehicles',
          queryParameters: {
            'organizationId': organizationId,
            'countryCode': countryCode,
            'page': page,
            'pageSize': pageSize,
          },
        );
        return DriverVehicleListResponseDto.fromJson(response.data as Map<String, dynamic>);
      });

  @override
  Future<DriverAvailabilityResponseDto> driverAvailability({
    required String organizationId,
    required String countryCode,
  }) =>
      _guarded(() async {
        final response = await _dio.get(
          '/v1/driver/availability',
          queryParameters: {'organizationId': organizationId, 'countryCode': countryCode},
        );
        return DriverAvailabilityResponseDto.fromJson(response.data as Map<String, dynamic>);
      });

  @override
  Future<DriverAvailabilityResponseDto> updateDriverAvailability(UpdateDriverAvailabilityDto body) => _guarded(() async {
        final response = await _dio.patch('/v1/driver/availability', data: body.toJson());
        return DriverAvailabilityResponseDto.fromJson(response.data as Map<String, dynamic>);
      });

  @override
  Future<DriverWorkFeedListResponseDto> driverWorkFeed({
    required String organizationId,
    required String countryCode,
    int page = 1,
    int pageSize = 25,
  }) =>
      _guarded(() async {
        final response = await _dio.get(
          '/v1/driver/work-feed',
          queryParameters: {
            'organizationId': organizationId,
            'countryCode': countryCode,
            'page': page,
            'pageSize': pageSize,
          },
        );
        return DriverWorkFeedListResponseDto.fromJson(response.data as Map<String, dynamic>);
      });
}
