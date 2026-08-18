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
}
