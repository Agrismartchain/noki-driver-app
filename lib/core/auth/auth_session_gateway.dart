/// Narrow interface the HTTP layer uses to read/refresh session tokens
/// without depending on `features/auth` (keeps `core/` free of feature
/// imports). Implemented by `features/auth/auth_controller.dart`.
abstract class AuthSessionGateway {
  /// Current access token, or null if signed out.
  Future<String?> currentAccessToken();

  /// Attempts one token refresh using the stored refresh token. Returns the
  /// new access token on success, or null if refresh is not possible/failed
  /// (in which case the caller must treat the session as expired).
  Future<String?> refreshAccessToken();

  /// Called by the HTTP layer when a refresh attempt was rejected by the
  /// backend (refresh token invalid/expired) - the session must be torn
  /// down and the user routed back to login.
  Future<void> onSessionExpired();
}
