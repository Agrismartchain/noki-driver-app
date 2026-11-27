import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/driver_api_client.dart';
import 'package:noki_driver_app/core/api/mfa/mfa_models.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';

import '../../fixtures/sample_responses.dart';

/// Exercises [DioDriverApiClient] directly against a canned HTTP transport -
/// no Riverpod, no [AuthController] - so these prove the actual
/// status-code-sniffing and error-body-parsing logic in
/// `lib/core/api/driver_api_client.dart`, independent of
/// `test/fixtures/fake_driver_api_client.dart`'s hand-maintained fake (which
/// could drift from the real client's behavior without anything failing).
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handler(options);

  @override
  void close({bool force = false}) {}
}

DriverApiClient _clientReturning(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://unit-test.invalid'));
  dio.httpClientAdapter = _FakeHttpClientAdapter(handler);
  return DioDriverApiClient(dio);
}

ResponseBody _jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
  final bytes = utf8.encode(jsonEncode(body));
  return ResponseBody.fromBytes(
    bytes,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  group('DioDriverApiClient.login', () {
    test('200 with tokens -> AuthLoginSuccess, never AuthLoginMfaChallenge', () async {
      final client = _clientReturning((options) async {
        expect(options.path, '/v1/auth/login');
        return _jsonResponse(sampleAuthTokens());
      });

      final result = await client.login(email: 'a@b.test', password: 'secret');

      expect(result, isA<AuthLoginSuccess>());
      expect((result as AuthLoginSuccess).tokens.accessToken, 'access-token-1');
    });

    test('202 with mfaStatus ENROLL -> AuthLoginMfaChallenge, never deserialized as tokens', () async {
      final client = _clientReturning(
        (options) async => _jsonResponse(
          sampleMfaChallenge(mfaStatus: 'ENROLL', challengeToken: 'chal-1'),
          statusCode: 202,
        ),
      );

      final result = await client.login(email: 'a@b.test', password: 'secret');

      expect(result, isA<AuthLoginMfaChallenge>());
      final challenge = (result as AuthLoginMfaChallenge).challenge;
      expect(challenge.mfaStatus, MfaChallengePurpose.enroll);
      expect(challenge.challengeToken, 'chal-1');
    });

    test('202 with mfaStatus VERIFY -> AuthLoginMfaChallenge', () async {
      final client = _clientReturning(
        (options) async => _jsonResponse(
          sampleMfaChallenge(mfaStatus: 'VERIFY', challengeToken: 'chal-2'),
          statusCode: 202,
        ),
      );

      final result = await client.login(email: 'a@b.test', password: 'secret');

      expect(result, isA<AuthLoginMfaChallenge>());
      expect((result as AuthLoginMfaChallenge).challenge.mfaStatus, MfaChallengePurpose.verify);
    });
  });

  group('DioDriverApiClient MFA endpoints', () {
    test('mfaEnrollStart posts the challenge token and parses the secret', () async {
      Map<String, dynamic>? sentBody;
      final client = _clientReturning((options) async {
        expect(options.path, '/v1/auth/mfa/challenge/enroll/start');
        sentBody = options.data as Map<String, dynamic>;
        return _jsonResponse(sampleMfaEnrollmentStart());
      });

      final result = await client.mfaEnrollStart(challengeToken: 'chal-1');

      expect(sentBody, {'challengeToken': 'chal-1'});
      expect(result.secretBase32, 'JBSWY3DPEHPK3PXP');
    });

    test('mfaEnrollConfirm posts challengeToken+code and parses recovery codes + tokens', () async {
      Map<String, dynamic>? sentBody;
      final client = _clientReturning((options) async {
        expect(options.path, '/v1/auth/mfa/challenge/enroll/confirm');
        sentBody = options.data as Map<String, dynamic>;
        return _jsonResponse(sampleMfaEnrollConfirm());
      });

      final result = await client.mfaEnrollConfirm(challengeToken: 'chal-1', code: '123456');

      expect(sentBody, {'challengeToken': 'chal-1', 'code': '123456'});
      expect(result.recoveryCodes, ['ABCD-EFGH-JKMN', 'PQRS-TUVW-XY23']);
      expect(result.tokens.accessToken, 'access-token-1');
    });

    test('mfaVerify with a code posts only challengeToken+code (no recoveryCode key)', () async {
      Map<String, dynamic>? sentBody;
      final client = _clientReturning((options) async {
        expect(options.path, '/v1/auth/mfa/challenge/verify');
        sentBody = options.data as Map<String, dynamic>;
        return _jsonResponse(sampleAuthTokens());
      });

      final result = await client.mfaVerify(challengeToken: 'chal-2', code: '123456');

      expect(sentBody, {'challengeToken': 'chal-2', 'code': '123456'});
      expect(result.accessToken, 'access-token-1');
    });

    test('mfaVerify with a recovery code posts only challengeToken+recoveryCode', () async {
      Map<String, dynamic>? sentBody;
      final client = _clientReturning((options) async {
        sentBody = options.data as Map<String, dynamic>;
        return _jsonResponse(sampleAuthTokens());
      });

      await client.mfaVerify(challengeToken: 'chal-2', recoveryCode: 'ABCD-EFGH-JKMN');

      expect(sentBody, {'challengeToken': 'chal-2', 'recoveryCode': 'ABCD-EFGH-JKMN'});
    });

    test('an invalid code (401 MFA_CODE_INVALID) surfaces as AppFailure.code', () async {
      final client = _clientReturning((options) async {
        return ResponseBody.fromBytes(
          utf8.encode(jsonEncode({'code': 'MFA_CODE_INVALID', 'message': 'The code is not valid'})),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await expectLater(
        client.mfaVerify(challengeToken: 'chal-2', code: '000000'),
        throwsA(
          isA<AppFailure>()
              .having((f) => f.type, 'type', AppFailureType.unauthenticated)
              .having((f) => f.code, 'code', 'MFA_CODE_INVALID'),
        ),
      );
    });

    test('an expired challenge (401 MFA_CHALLENGE_INVALID) surfaces as AppFailure.code', () async {
      final client = _clientReturning((options) async {
        return ResponseBody.fromBytes(
          utf8.encode(
            jsonEncode({'code': 'MFA_CHALLENGE_INVALID', 'message': 'The sign-in step expired; sign in again'}),
          ),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await expectLater(
        client.mfaVerify(challengeToken: 'chal-2', code: '000000'),
        throwsA(
          isA<AppFailure>()
              .having((f) => f.type, 'type', AppFailureType.unauthenticated)
              .having((f) => f.code, 'code', 'MFA_CHALLENGE_INVALID'),
        ),
      );
    });

    test('too many incorrect codes (429 MFA_LOCKED) surfaces as rateLimited with the code attached', () async {
      final client = _clientReturning((options) async {
        return ResponseBody.fromBytes(
          utf8.encode(
            jsonEncode({'code': 'MFA_LOCKED', 'message': 'Too many incorrect codes; try again later'}),
          ),
          429,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await expectLater(
        client.mfaVerify(challengeToken: 'chal-2', code: '000000'),
        throwsA(
          isA<AppFailure>()
              .having((f) => f.type, 'type', AppFailureType.rateLimited)
              .having((f) => f.code, 'code', 'MFA_LOCKED'),
        ),
      );
    });
  });
}
