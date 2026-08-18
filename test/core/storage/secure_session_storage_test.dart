import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/fake_session_storage.dart';

/// Exercises the [SecureSessionStorage] contract that every implementation
/// (the real Keystore/Keychain-backed one and this in-memory fake) must
/// satisfy - round-trip writes, absence before any write, and a full wipe
/// on `clear()`.
void main() {
  group('SecureSessionStorage contract', () {
    test('returns null for everything before any write', () async {
      final storage = FakeSecureSessionStorage();
      expect(await storage.readAccessToken(), isNull);
      expect(await storage.readRefreshToken(), isNull);
      expect(await storage.readAccessTokenExpiresAt(), isNull);
    });

    test('round-trips the access token, refresh token and expiry', () async {
      final storage = FakeSecureSessionStorage();
      await storage.writeAccessToken('access-1');
      await storage.writeRefreshToken('refresh-1');
      await storage.writeAccessTokenExpiresAt(1000);

      expect(await storage.readAccessToken(), 'access-1');
      expect(await storage.readRefreshToken(), 'refresh-1');
      expect(await storage.readAccessTokenExpiresAt(), 1000);
    });

    test('clear() wipes every stored credential', () async {
      final storage = FakeSecureSessionStorage();
      await storage.writeAccessToken('access-1');
      await storage.writeRefreshToken('refresh-1');
      await storage.writeAccessTokenExpiresAt(1000);

      await storage.clear();

      expect(await storage.readAccessToken(), isNull);
      expect(await storage.readRefreshToken(), isNull);
      expect(await storage.readAccessTokenExpiresAt(), isNull);
    });
  });
}
