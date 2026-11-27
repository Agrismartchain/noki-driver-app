import '../../core/api/generated/driver_models.generated.dart';
import '../../core/api/mfa/mfa_models.dart';
import '../../core/errors/app_failure.dart';

/// Discriminated auth/session status. The UI shell (`app/app_shell.dart`)
/// switches on [AuthStatus] to decide between a splash, the login screen,
/// the access-denied screen, or the authenticated app - never rendering an
/// operational screen before the role guard has resolved (see README
/// "Session bootstrap").
enum AuthStatus {
  /// Reading secure storage / validating a restored session. Shown as a
  /// blocking splash - no operational UI is built during this state.
  bootstrapping,
  unauthenticated,
  authenticating,

  /// Password step succeeded; the account has no active authenticator yet.
  /// [AuthState.mfaChallenge] holds the challenge token (and, once
  /// requested, the enrollment secret). No tokens exist and
  /// `/v1/driver/context` has not been called.
  mfaEnrollRequired,

  /// Enrollment just completed - [AuthState.pendingRecoveryCodes] holds the
  /// one-time recovery codes that must be shown and acknowledged before the
  /// session they came with is actually used. Tokens are already issued by
  /// the backend at this point but deliberately not yet persisted/used here
  /// (see [AuthController.acknowledgeRecoveryCodes]).
  mfaRecoveryCodesPending,

  /// Password step succeeded; the account already has an active
  /// authenticator and must prove it. [AuthState.mfaChallenge] holds the
  /// challenge token. No tokens exist and `/v1/driver/context` has not been
  /// called.
  mfaVerifyRequired,

  /// Signed in, backend confirms at least one Driver profile.
  authenticated,

  /// Signed in, but the account has no Driver profile anywhere - the role
  /// guard rejected it (see DRIVER-APP-01 section 15).
  accessDenied,
}

/// The one piece of state an in-progress MFA challenge needs client-side.
/// [challengeToken] is an opaque, short-lived proof that the password step
/// succeeded - never an access token, never persisted to secure storage
/// (session storage holds a completed session's tokens only), never logged.
class MfaChallengeState {
  const MfaChallengeState({
    required this.challengeToken,
    required this.expiresAt,
    this.enrollment,
  });

  final String challengeToken;

  /// Client-side estimate of [AuthMfaChallengeResponseDto.challengeExpiresIn]
  /// resolved against wall-clock time. The backend is the final authority -
  /// this only lets the UI show a countdown and react promptly instead of
  /// waiting for a round trip to find out the challenge died.
  final DateTime expiresAt;

  /// Populated once `startMfaEnrollment()` returns, for the `ENROLL` path
  /// only. Shown to the driver exactly once; never re-fetched once set
  /// (re-calling enroll/start would reject with `MFA_ALREADY_ENROLLED` once
  /// a pending enrollment exists, and a wrong first code should let the
  /// driver retry against the *same* secret, not a new one).
  final MfaEnrollmentStartResponseDto? enrollment;

  MfaChallengeState copyWith({MfaEnrollmentStartResponseDto? enrollment}) {
    return MfaChallengeState(
      challengeToken: challengeToken,
      expiresAt: expiresAt,
      enrollment: enrollment ?? this.enrollment,
    );
  }
}

/// Recovery codes produced by a just-confirmed enrollment, held only long
/// enough for the driver to acknowledge having saved them. The tokens that
/// came with them are carried here too (not yet persisted - see
/// [AuthStatus.mfaRecoveryCodesPending]'s doc comment) so
/// `acknowledgeRecoveryCodes()` can complete the session without another
/// network call.
class PendingMfaSession {
  const PendingMfaSession({required this.recoveryCodes, required this.tokens});
  final List<String> recoveryCodes;
  final AuthTokensResponseDto tokens;
}

class AuthState {
  const AuthState({
    required this.status,
    this.driverContext,
    this.avatarUrl,
    this.failure,
    this.mfaChallenge,
    this.pendingRecoveryCodes,
  });

  const AuthState.initial() : this(status: AuthStatus.bootstrapping);

  final AuthStatus status;
  final DriverContextResponseDto? driverContext;
  final String? avatarUrl;
  final AppFailure? failure;
  final MfaChallengeState? mfaChallenge;
  final PendingMfaSession? pendingRecoveryCodes;

  AuthState copyWith({
    AuthStatus? status,
    DriverContextResponseDto? driverContext,
    String? avatarUrl,
    AppFailure? failure,
    MfaChallengeState? mfaChallenge,
    PendingMfaSession? pendingRecoveryCodes,
    bool clearFailure = false,
    bool clearDriverContext = false,
    bool clearAvatarUrl = false,
    bool clearMfaChallenge = false,
    bool clearPendingRecoveryCodes = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      driverContext: clearDriverContext ? null : (driverContext ?? this.driverContext),
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      failure: clearFailure ? null : (failure ?? this.failure),
      mfaChallenge: clearMfaChallenge ? null : (mfaChallenge ?? this.mfaChallenge),
      pendingRecoveryCodes: clearPendingRecoveryCodes
          ? null
          : (pendingRecoveryCodes ?? this.pendingRecoveryCodes),
    );
  }
}
