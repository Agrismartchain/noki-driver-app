import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/driver_api_client.dart';
import '../../core/api/generated/driver_models.generated.dart';
import '../../core/auth/auth_session_gateway.dart';
import '../../core/errors/app_failure.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/secure_session_storage.dart';
import '../../core/storage/storage_providers.dart';
import 'auth_state.dart';

export 'auth_state.dart';

/// Owns the authenticated session end-to-end: login, session bootstrap on
/// app launch, token refresh (as [AuthSessionGateway], consumed by the HTTP
/// layer), the Driver role guard, and logout.
///
/// Deliberately depends only on [DriverApiClient] and [SecureSessionStorage]
/// abstractions (both overridable in tests), never on Dio or
/// flutter_secure_storage directly.
class AuthController extends Notifier<AuthState> implements AuthSessionGateway {
  late final DriverApiClient _apiClient;
  late final SecureSessionStorage _storage;

  String? _cachedAccessToken;

  @override
  AuthState build() {
    _apiClient = ref.watch(driverApiClientProvider);
    _storage = ref.watch(secureSessionStorageProvider);
    Future.microtask(_bootstrap);
    return const AuthState.initial();
  }

  Future<void> _bootstrap() async {
    final accessToken = await _storage.readAccessToken();
    final refreshToken = await _storage.readRefreshToken();

    if (accessToken == null && refreshToken == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    _cachedAccessToken = accessToken;

    try {
      final context = await _apiClient.driverContext();
      state = _resolveRoleGuard(context);
    } on AppFailure catch (failure) {
      if (failure.type == AppFailureType.unauthenticated || failure.type == AppFailureType.forbidden) {
        await _storage.clear();
        _cachedAccessToken = null;
        state = const AuthState(status: AuthStatus.unauthenticated);
      } else {
        // Transient (network/timeout/server) failure while restoring a
        // session we otherwise have tokens for: do not silently show
        // operational screens, but do not destroy the stored session either
        // - the user can retry from the login screen.
        AppLogger.warning('Session restore failed transiently', data: {'type': failure.type.name});
        state = AuthState(status: AuthStatus.unauthenticated, failure: failure);
      }
    }
  }

  AuthState _resolveRoleGuard(DriverContextResponseDto context) {
    if (context.profiles.isEmpty) {
      return AuthState(status: AuthStatus.accessDenied, driverContext: context);
    }
    return AuthState(status: AuthStatus.authenticated, driverContext: context);
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.authenticating, clearFailure: true);
    try {
      final tokens = await _apiClient.login(email: email, password: password);
      await _persistTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        accessTokenExpiresIn: tokens.accessTokenExpiresIn,
      );

      final context = await _apiClient.driverContext();
      state = _resolveRoleGuard(context);
    } on AppFailure catch (failure) {
      state = AuthState(status: AuthStatus.unauthenticated, failure: failure);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } on AppFailure catch (failure) {
      // Best-effort server-side revoke; local session is cleared regardless.
      AppLogger.warning('Logout call failed, clearing session locally anyway', data: {'type': failure.type.name});
    }
    await _storage.clear();
    _cachedAccessToken = null;
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _persistTokens({
    required String accessToken,
    required String refreshToken,
    required num accessTokenExpiresIn,
  }) async {
    _cachedAccessToken = accessToken;
    await _storage.writeAccessToken(accessToken);
    await _storage.writeRefreshToken(refreshToken);
    await _storage.writeAccessTokenExpiresAt(
      DateTime.now().millisecondsSinceEpoch + (accessTokenExpiresIn.toInt() * 1000),
    );
  }

  // --- AuthSessionGateway (consumed by the HTTP interceptor) -------------

  @override
  Future<String?> currentAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _storage.readAccessToken();
    return _cachedAccessToken;
  }

  @override
  Future<String?> refreshAccessToken() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) return null;
    try {
      final tokens = await _apiClient.refresh(refreshToken: refreshToken);
      await _persistTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        accessTokenExpiresIn: tokens.accessTokenExpiresIn,
      );
      return tokens.accessToken;
    } on AppFailure {
      return null;
    }
  }

  @override
  Future<void> onSessionExpired() async {
    await _storage.clear();
    _cachedAccessToken = null;
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
