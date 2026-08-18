import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstraction over secure, encrypted-at-rest storage of session material.
///
/// Backed by Android Keystore / iOS Keychain via `flutter_secure_storage`.
/// Never backed by `SharedPreferences`, files, or logs. Implemented as an
/// interface so tests can swap in an in-memory fake without touching the
/// platform channel (see `test/fixtures/fake_session_storage.dart`).
abstract class SecureSessionStorage {
  Future<void> writeAccessToken(String token);
  Future<String?> readAccessToken();

  Future<void> writeRefreshToken(String token);
  Future<String?> readRefreshToken();

  /// Epoch-millis wall-clock expiry of the current access token.
  Future<void> writeAccessTokenExpiresAt(int epochMillis);
  Future<int?> readAccessTokenExpiresAt();

  /// Clears every stored credential. Always called on logout and on any
  /// unrecoverable auth failure (e.g. refresh token rejected).
  Future<void> clear();
}

class FlutterSecureSessionStorage implements SecureSessionStorage {
  FlutterSecureSessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'noki.session.access_token';
  static const _refreshTokenKey = 'noki.session.refresh_token';
  static const _accessTokenExpiresAtKey = 'noki.session.access_token_expires_at';

  @override
  Future<void> writeAccessToken(String token) => _storage.write(key: _accessTokenKey, value: token);

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<void> writeRefreshToken(String token) => _storage.write(key: _refreshTokenKey, value: token);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> writeAccessTokenExpiresAt(int epochMillis) =>
      _storage.write(key: _accessTokenExpiresAtKey, value: epochMillis.toString());

  @override
  Future<int?> readAccessTokenExpiresAt() async {
    final raw = await _storage.read(key: _accessTokenExpiresAtKey);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _accessTokenExpiresAtKey);
  }
}
