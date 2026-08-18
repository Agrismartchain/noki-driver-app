import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import '../config/app_config_provider.dart';
import 'dio_client_factory.dart';
import 'driver_api_client.dart';

/// The single [Dio] instance for the whole app, wired to the current
/// [AppConfig] and to `AuthController` (which implements
/// `AuthSessionGateway` - see `features/auth/auth_providers.dart`) for
/// bearer-token injection and 401 refresh handling.
final driverApiDioProvider = Provider<Dio>((ref) {
  return buildDriverApiDio(
    config: ref.watch(appConfigProvider),
    sessionGateway: ref.watch(authSessionGatewayProvider),
  );
});

final driverApiClientProvider = Provider<DriverApiClient>((ref) {
  return DioDriverApiClient(ref.watch(driverApiDioProvider));
});
