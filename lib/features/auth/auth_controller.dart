import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/driver_api_client.dart';
import '../../core/api/generated/driver_models.generated.dart';
import '../../core/auth/auth_session_gateway.dart';
import '../../core/errors/app_failure.dart';
import '../../core/logging/app_logger.dart';
import '../../core/routing/app_router.dart';
import '../../core/storage/secure_session_storage.dart';
import '../../core/storage/storage_providers.dart';
import 'auth_providers.dart';
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
  late final SecureSessionStorage _storage;

  /// Resolved lazily (`ref.read`, not captured via `ref.watch` in [build]) -
  /// resolving it eagerly inside [build] reads `authControllerProvider`
  /// while it is still being built, a genuine `CircularDependencyError`
  /// (see DRIVER-APP-01R3). Safe to read from any async method now that
  /// `authSessionGatewayProvider` no longer creates a Riverpod-tracked
  /// dependency back onto `authControllerProvider` at all - see
  /// [AuthSessionGatewayHolder]'s doc comment in `auth_providers.dart` for
  /// why that Riverpod-graph edge, not `flutter_secure_storage`, was the
  /// real cause of a real-device-only indefinite hang on login (DRIVER-APP-01R4).
  DriverApiClient get _apiClient => ref.read(driverApiClientProvider);

  /// Generous but finite upper bound on persisting the session after a
  /// successful login. Storage writes normally take single-digit
  /// milliseconds; this exists purely so a genuinely stuck write can never
  /// leave [AuthState.status] on [AuthStatus.authenticating] (an indefinite
  /// UI spinner) forever - see the top-level `catch` in [login].
  static const _storageTimeout = Duration(seconds: 10);

  String? _cachedAccessToken;

  @override
  AuthState build() {
    _storage = ref.watch(secureSessionStorageProvider);
    // One-time, untracked wiring into the plain AuthSessionGatewayHolder -
    // see its doc comment in auth_providers.dart for why this must never be
    // `ref.watch(authControllerProvider.notifier)` from the gateway side.
    ref.read(authSessionGatewayProvider).delegate = this;
    // Forwards status changes to go_router's refresh signal via `listenSelf`
    // (a Notifier observing its own state) plus a `ref.read` of an unrelated,
    // dependency-free provider - never a `ref.watch`/`ref.listen` on
    // `authControllerProvider` from another provider's build, and never
    // anything reading Riverpod from inside `redirect` or from a descendant
    // widget's first build pass. Both were tried and reproducibly caused
    // real, distinct failures on real Android (a UI-thread hang, then a
    // `CircularDependencyError`) - see DRIVER-APP-01R2, RD-1.
    final routerRefreshListenable = ref.read(routerRefreshListenableProvider);
    listenSelf((previous, next) {
      // `listenSelf`'s callback also fires once immediately after this very
      // build completes, with `previous == null` - not a real transition,
      // just this Notifier's own construction echoing back. Forwarding that
      // as a "status changed" notification fires `refresh()` synchronously
      // while this provider's own first read (`RootGate`, nested inside the
      // same initial widget-mount pass) is still on the call stack, which
      // go_router's `Router` widget reacts to with `setState()` mid-build -
      // a distinct real crash from DRIVER-APP-01R3's CircularDependencyError,
      // surfaced only once that one was fixed. `previous == null` is
      // filtered out; every actual transition still forwards normally.
      if (previous != null && previous.status != next.status) {
        routerRefreshListenable.status = next.status;
        routerRefreshListenable.refresh();
      }
    });
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
      ).timeout(_storageTimeout);

      final context = await _apiClient.driverContext();
      state = _resolveRoleGuard(context);
    } on AppFailure catch (failure) {
      state = AuthState(status: AuthStatus.unauthenticated, failure: failure);
    } catch (error) {
      // Defense in depth: `state` must never be left on `authenticating`
      // (an indefinite UI spinner) regardless of what goes wrong - a
      // TimeoutException from the persistence step above, or any other
      // unexpected exception. Never logs `error` itself (could carry
      // platform/storage exception details) - only its type. See
      // DRIVER-APP-01R4.
      AppLogger.warning('Login failed unexpectedly', data: {'errorType': error.runtimeType.toString()});
      state = const AuthState(status: AuthStatus.unauthenticated, failure: AppFailure(AppFailureType.unknown));
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
