import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/driver_api_client.dart';
import '../../core/api/generated/driver_models.generated.dart';
import '../../core/api/mfa/mfa_models.dart';
import '../../core/auth/auth_session_gateway.dart';
import '../../core/errors/app_failure.dart';
import '../../core/logging/app_logger.dart';
import '../../core/routing/app_router.dart';
import '../../core/storage/secure_session_storage.dart';
import '../../core/storage/storage_providers.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

export 'auth_state.dart';

/// The backend's machine-readable code (see `AppFailure.code`) for an
/// opaque, short-lived MFA challenge token that is missing, malformed, or
/// past `challengeExpiresIn` - thrown by `AuthTokenService.verifyMfaChallengeToken`
/// on every one of the three pre-session MFA endpoints. There is no retry
/// possible once this happens: the only way forward is signing in again.
const _mfaChallengeInvalidCode = 'MFA_CHALLENGE_INVALID';

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
    final avatarUrl = _apiClient.lastContextAvatarUrl;
    if (context.profiles.isEmpty) {
      return AuthState(
        status: AuthStatus.accessDenied,
        driverContext: context,
        avatarUrl: avatarUrl,
      );
    }
    return AuthState(
      status: AuthStatus.authenticated,
      driverContext: context,
      avatarUrl: avatarUrl,
    );
  }

  /// Updates the authenticated driver's avatar URL in memory immediately after
  /// saving, replacing, or removing the photo via NOKI media storage.
  void updateAvatarUrl(String? avatarUrl) {
    state = avatarUrl == null
        ? state.copyWith(clearAvatarUrl: true)
        : state.copyWith(avatarUrl: avatarUrl);
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      clearFailure: true,
      clearMfaChallenge: true,
      clearPendingRecoveryCodes: true,
    );
    try {
      final result = await _apiClient.login(email: email, password: password);
      switch (result) {
        case AuthLoginSuccess(:final tokens):
          await _completeSession(tokens);
        case AuthLoginMfaChallenge(:final challenge):
          // Deliberately not persisting anything and not calling
          // driverContext() here: the password step succeeded but no
          // session exists yet - see MfaChallengeState's doc comment.
          state = AuthState(
            status: challenge.mfaStatus == MfaChallengePurpose.enroll
                ? AuthStatus.mfaEnrollRequired
                : AuthStatus.mfaVerifyRequired,
            mfaChallenge: MfaChallengeState(
              challengeToken: challenge.challengeToken,
              expiresAt: DateTime.now().add(
                Duration(seconds: challenge.challengeExpiresIn.toInt()),
              ),
            ),
          );
      }
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

  /// Begins two-factor setup for the current `ENROLL` challenge. Safe to
  /// call more than once (e.g. the enroll screen retrying after a transient
  /// network error) as long as no enrollment secret has been returned yet -
  /// see [MfaChallengeState.enrollment]'s doc comment for why it is never
  /// re-fetched once set.
  Future<void> startMfaEnrollment() async {
    final challenge = state.mfaChallenge;
    if (challenge == null || state.status != AuthStatus.mfaEnrollRequired) return;
    state = state.copyWith(clearFailure: true);
    try {
      final enrollment = await _apiClient.mfaEnrollStart(
        challengeToken: challenge.challengeToken,
      );
      state = state.copyWith(
        mfaChallenge: challenge.copyWith(enrollment: enrollment),
      );
    } on AppFailure catch (failure) {
      _handleMfaChallengeFailure(failure);
    } catch (error) {
      AppLogger.warning(
        'MFA enrollment start failed unexpectedly',
        data: {'errorType': error.runtimeType.toString()},
      );
      state = state.copyWith(
        failure: const AppFailure(AppFailureType.unknown),
      );
    }
  }

  /// Confirms enrollment with the first authenticator code. On success the
  /// account has an active second factor and a session exists server-side,
  /// but [acknowledgeRecoveryCodes] must still be called to actually use it
  /// - see [AuthStatus.mfaRecoveryCodesPending].
  Future<void> confirmMfaEnrollment({required String code}) async {
    final challenge = state.mfaChallenge;
    if (challenge == null || state.status != AuthStatus.mfaEnrollRequired) return;
    state = state.copyWith(clearFailure: true);
    try {
      final result = await _apiClient.mfaEnrollConfirm(
        challengeToken: challenge.challengeToken,
        code: code,
      );
      state = AuthState(
        status: AuthStatus.mfaRecoveryCodesPending,
        pendingRecoveryCodes: PendingMfaSession(
          recoveryCodes: result.recoveryCodes,
          tokens: result.tokens,
        ),
      );
    } on AppFailure catch (failure) {
      _handleMfaChallengeFailure(failure);
    } catch (error) {
      AppLogger.warning(
        'MFA enrollment confirm failed unexpectedly',
        data: {'errorType': error.runtimeType.toString()},
      );
      state = state.copyWith(
        failure: const AppFailure(AppFailureType.unknown),
      );
    }
  }

  /// The driver has confirmed they saved the one-time recovery codes.
  /// Persists the tokens the backend already issued at enrollment-confirm
  /// time and only now calls `driverContext()` - see
  /// [AuthStatus.mfaRecoveryCodesPending]'s doc comment.
  Future<void> acknowledgeRecoveryCodes() async {
    final pending = state.pendingRecoveryCodes;
    if (pending == null || state.status != AuthStatus.mfaRecoveryCodesPending) return;
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      await _completeSession(pending.tokens);
    } on AppFailure catch (failure) {
      // Mirrors `login()`'s own handling of a `_completeSession` failure:
      // the driver signs in again from scratch. The account is already
      // enrolled server-side at this point, so the next login goes
      // straight to `mfaVerifyRequired`, never back through enrollment.
      state = AuthState(status: AuthStatus.unauthenticated, failure: failure);
    } catch (error) {
      AppLogger.warning(
        'Completing session after MFA enrollment failed unexpectedly',
        data: {'errorType': error.runtimeType.toString()},
      );
      state = const AuthState(status: AuthStatus.unauthenticated, failure: AppFailure(AppFailureType.unknown));
    }
  }

  /// Completes sign-in for the current `VERIFY` challenge with either an
  /// authenticator code or a one-time recovery code (exactly one must be
  /// non-null - see `MfaChallengeVerifyRequestDto`).
  Future<void> verifyMfa({String? code, String? recoveryCode}) async {
    final challenge = state.mfaChallenge;
    if (challenge == null || state.status != AuthStatus.mfaVerifyRequired) return;
    state = state.copyWith(clearFailure: true);
    try {
      final tokens = await _apiClient.mfaVerify(
        challengeToken: challenge.challengeToken,
        code: code,
        recoveryCode: recoveryCode,
      );
      await _completeSession(tokens);
    } on AppFailure catch (failure) {
      _handleMfaChallengeFailure(failure);
    } catch (error) {
      AppLogger.warning(
        'MFA verify failed unexpectedly',
        data: {'errorType': error.runtimeType.toString()},
      );
      state = state.copyWith(
        failure: const AppFailure(AppFailureType.unknown),
      );
    }
  }

  /// A wrong code (`MFA_CODE_INVALID`) keeps the driver on the same
  /// enroll/verify screen with the same challenge token, so they can retry -
  /// the server allows several attempts before locking the factor
  /// (`MFA_LOCKED`, surfaced the same way: stay put, show the failure, the
  /// lockout is time-bounded). Anything else - most importantly an expired
  /// or otherwise invalid challenge token (`MFA_CHALLENGE_INVALID`) - cannot
  /// be retried in place: the whole pre-session challenge is dead, so this
  /// resets all the way back to the login screen with the failure attached
  /// for context.
  void _handleMfaChallengeFailure(AppFailure failure) {
    if (failure.code == _mfaChallengeInvalidCode) {
      state = AuthState(status: AuthStatus.unauthenticated, failure: failure);
      return;
    }
    state = state.copyWith(failure: failure);
  }

  /// Persists tokens and resolves the Driver role guard - the one and only
  /// path by which [AuthState.status] reaches [AuthStatus.authenticated],
  /// whether sign-in needed no second factor, just finished enrollment, or
  /// just verified an existing one. `driverContext()` is never called
  /// before this - see this method's three callers.
  Future<void> _completeSession(AuthTokensResponseDto tokens) async {
    await _persistTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      accessTokenExpiresIn: tokens.accessTokenExpiresIn,
    ).timeout(_storageTimeout);

    final context = await _apiClient.driverContext();
    state = _resolveRoleGuard(context);
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
