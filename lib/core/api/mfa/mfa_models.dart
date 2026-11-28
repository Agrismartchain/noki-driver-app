/// Hand-written models for the privileged-account MFA (TOTP) surface of
/// `/v1/auth/*`, introduced after this repo's contract was last regenerated
/// (`contract/lock.json` -> `includedOperationIds` has no `MfaController_*`
/// entries - see `tool/generate_api_models.mjs`'s header comment: it only
/// reads the checked-in `../noki-shared-contracts` spec, which is not
/// available in every environment that builds this app).
///
/// Every shape below is copied field-for-field from the real, deployed
/// backend source (not invented):
///   - `src/modules/auth/auth.controller.ts` (`AuthController.login`'s
///     `ApiAcceptedResponse`)
///   - `src/modules/auth/auth.service.ts` (`AuthMfaChallenge`)
///   - `src/modules/auth/mfa/mfa.controller.ts` (`MfaController`)
///   - `src/modules/auth/mfa/dto/mfa.dto.ts`
/// as of `noki-api` branch `cloud/customer-transverse-b7p-r2`.
///
/// TODO(contract-sync): once `../noki-shared-contracts` publishes these
/// operations, fold them into `contract/lock.json` ->
/// `includedOperationIds` and regenerate via `tool/generate_api_models.mjs`,
/// then delete this file in favor of the generated equivalents.
library;

import '../generated/driver_models.generated.dart';

/// Mirrors the backend's `AuthMfaChallenge.mfaStatus` / the JWT `pur` claim.
enum MfaChallengePurpose {
  /// The account already has an active authenticator; enter its code.
  verify,

  /// The account must set up an authenticator before a session can be
  /// issued.
  enroll;

  static MfaChallengePurpose fromWire(String raw) {
    switch (raw) {
      case 'VERIFY':
        return MfaChallengePurpose.verify;
      case 'ENROLL':
        return MfaChallengePurpose.enroll;
      default:
        throw ArgumentError.value(raw, 'mfaStatus', 'Unknown MFA challenge status');
    }
  }
}

/// `POST /v1/auth/login` -> 202 body (`AuthMfaChallengeResponseDto` on the
/// backend). Never carries tokens: the password step succeeded but no
/// session exists yet.
class AuthMfaChallengeResponseDto {
  const AuthMfaChallengeResponseDto({
    required this.mfaStatus,
    required this.challengeToken,
    required this.challengeExpiresIn,
  });

  final MfaChallengePurpose mfaStatus;

  /// Opaque, short-lived proof that the password step succeeded. Not an
  /// access token - carries no API permissions by itself.
  final String challengeToken;

  /// Seconds remaining before [challengeToken] stops being accepted.
  final num challengeExpiresIn;

  factory AuthMfaChallengeResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthMfaChallengeResponseDto(
      mfaStatus: MfaChallengePurpose.fromWire(json['mfaStatus'] as String),
      challengeToken: json['challengeToken'] as String,
      challengeExpiresIn: (json['challengeExpiresIn'] as num?) ?? 0,
    );
  }
}

/// Result of `POST /v1/auth/login`: either a full session, or a pre-session
/// MFA challenge. Dart's exhaustiveness checking on this sealed type is what
/// makes it impossible to repeat the original bug (deserializing every
/// `/v1/auth/login` response as [AuthTokensResponseDto] regardless of
/// `mfaStatus`) - every caller of [DriverApiClient.login] must switch on
/// both cases.
sealed class AuthLoginResult {
  const AuthLoginResult();
}

final class AuthLoginSuccess extends AuthLoginResult {
  const AuthLoginSuccess(this.tokens);
  final AuthTokensResponseDto tokens;
}

final class AuthLoginMfaChallenge extends AuthLoginResult {
  const AuthLoginMfaChallenge(this.challenge);
  final AuthMfaChallengeResponseDto challenge;
}

/// `POST /v1/auth/mfa/challenge/enroll/start` request body.
class MfaChallengeEnrollStartRequestDto {
  const MfaChallengeEnrollStartRequestDto({required this.challengeToken});
  final String challengeToken;
  Map<String, dynamic> toJson() => {'challengeToken': challengeToken};
}

/// `POST /v1/auth/mfa/challenge/enroll/start` -> 200 body
/// (`MfaEnrollmentStartResponseDto` on the backend). The shared secret is
/// shown exactly once, here; only its encrypted form exists afterwards.
/// Never persist this to disk and never log it (see `AppLogger`'s redacted
/// keys).
class MfaEnrollmentStartResponseDto {
  const MfaEnrollmentStartResponseDto({
    required this.secretBase32,
    required this.otpauthUri,
    required this.issuer,
  });

  final String secretBase32;
  final String otpauthUri;
  final String issuer;

  factory MfaEnrollmentStartResponseDto.fromJson(Map<String, dynamic> json) {
    return MfaEnrollmentStartResponseDto(
      secretBase32: json['secretBase32'] as String,
      otpauthUri: json['otpauthUri'] as String,
      issuer: json['issuer'] as String,
    );
  }
}

/// `POST /v1/auth/mfa/challenge/enroll/confirm` request body.
class MfaChallengeEnrollConfirmRequestDto {
  const MfaChallengeEnrollConfirmRequestDto({
    required this.challengeToken,
    required this.code,
  });
  final String challengeToken;
  final String code;
  Map<String, dynamic> toJson() => {
    'challengeToken': challengeToken,
    'code': code,
  };
}

/// `POST /v1/auth/mfa/challenge/enroll/confirm` -> 200 body
/// (`MfaEnrollConfirmChallengeResponseDto` on the backend): the flat union
/// of recovery codes (shown once) and a full token set. [tokens] is parsed
/// from the very same JSON object - the backend spreads
/// `MfaRecoveryCodesResponseDto` and `AuthTokensResponseDto` together on the
/// wire rather than nesting them.
class MfaEnrollConfirmResponseDto {
  const MfaEnrollConfirmResponseDto({
    required this.recoveryCodes,
    required this.tokens,
  });

  /// One-time recovery codes. Must be shown to the driver and acknowledged
  /// before the session is considered usable - there is no way to retrieve
  /// them again later.
  final List<String> recoveryCodes;
  final AuthTokensResponseDto tokens;

  factory MfaEnrollConfirmResponseDto.fromJson(Map<String, dynamic> json) {
    return MfaEnrollConfirmResponseDto(
      recoveryCodes: (json['recoveryCodes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      tokens: AuthTokensResponseDto.fromJson(json),
    );
  }
}

/// `POST /v1/auth/mfa/challenge/verify` request body. Exactly one of [code]
/// (six-digit authenticator code) or [recoveryCode] (one-time recovery
/// code) is set.
class MfaChallengeVerifyRequestDto {
  const MfaChallengeVerifyRequestDto({
    required this.challengeToken,
    this.code,
    this.recoveryCode,
  }) : assert(
         (code == null) != (recoveryCode == null),
         'Exactly one of code or recoveryCode must be set',
       );

  final String challengeToken;
  final String? code;
  final String? recoveryCode;

  Map<String, dynamic> toJson() => {
    'challengeToken': challengeToken,
    if (code != null) 'code': code,
    if (recoveryCode != null) 'recoveryCode': recoveryCode,
  };
}
