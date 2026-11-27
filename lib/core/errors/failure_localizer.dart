import 'package:flutter/widgets.dart';

import '../i18n/generated/app_localizations.dart';
import 'app_failure.dart';

/// Turns an [AppFailure] into the one user-facing string it should ever
/// produce. Technical detail (status code, raw backend message) stays in
/// logs only - see AppLogger.
String localizeFailure(BuildContext context, AppFailure failure) {
  final l10n = AppLocalizations.of(context);
  // Several distinct MFA failures all share one AppFailureType (every one
  // of them is a 401 `unauthenticated` - see mfa.service.ts) but need
  // different copy, so these are checked by the backend's structured
  // `code` first; anything else falls through to the generic type switch
  // below unchanged.
  switch (failure.code) {
    case 'MFA_CODE_INVALID':
      return l10n.errorMfaCodeInvalid;
    case 'MFA_CHALLENGE_INVALID':
      return l10n.errorMfaChallengeExpired;
    case 'MFA_LOCKED':
      return l10n.errorMfaLocked;
  }
  switch (failure.type) {
    case AppFailureType.network:
      return l10n.errorNetwork;
    case AppFailureType.timeout:
      return l10n.errorTimeout;
    case AppFailureType.unauthenticated:
      return l10n.errorUnauthenticated;
    case AppFailureType.forbidden:
      return l10n.errorForbidden;
    case AppFailureType.notFound:
      return l10n.errorNotFound;
    case AppFailureType.validation:
      return l10n.errorValidation;
    case AppFailureType.conflict:
      return l10n.errorConflict;
    case AppFailureType.rateLimited:
      return l10n.errorRateLimited;
    case AppFailureType.server:
      return l10n.errorServer;
    case AppFailureType.unknown:
      return l10n.errorUnknown;
  }
}
