import '../../core/api/generated/driver_models.generated.dart';
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

  /// Signed in, backend confirms at least one Driver profile.
  authenticated,

  /// Signed in, but the account has no Driver profile anywhere - the role
  /// guard rejected it (see DRIVER-APP-01 section 15).
  accessDenied,
}

class AuthState {
  const AuthState({
    required this.status,
    this.driverContext,
    this.failure,
  });

  const AuthState.initial() : this(status: AuthStatus.bootstrapping);

  final AuthStatus status;
  final DriverContextResponseDto? driverContext;
  final AppFailure? failure;

  AuthState copyWith({
    AuthStatus? status,
    DriverContextResponseDto? driverContext,
    AppFailure? failure,
    bool clearFailure = false,
    bool clearDriverContext = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      driverContext: clearDriverContext ? null : (driverContext ?? this.driverContext),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}
