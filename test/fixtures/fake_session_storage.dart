import 'package:noki_driver_app/core/storage/secure_session_storage.dart';

/// In-memory [SecureSessionStorage] used across tests instead of touching
/// the real platform channel (Android Keystore / iOS Keychain) that backs
/// [FlutterSecureSessionStorage].
class FakeSecureSessionStorage implements SecureSessionStorage {
  String? _accessToken;
  String? _refreshToken;
  int? _accessTokenExpiresAt;

  @override
  Future<void> writeAccessToken(String token) async => _accessToken = token;

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<void> writeRefreshToken(String token) async => _refreshToken = token;

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<void> writeAccessTokenExpiresAt(int epochMillis) async => _accessTokenExpiresAt = epochMillis;

  @override
  Future<int?> readAccessTokenExpiresAt() async => _accessTokenExpiresAt;

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _accessTokenExpiresAt = null;
  }
}
