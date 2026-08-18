import 'package:flutter/widgets.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';

/// Maps the real `DriverMissionResponseDtoStatus` enum to a localized label
/// and a semantic (background, foreground) color pair. Pure/unit-testable on
/// purpose - no BuildContext-only state, so status presentation logic can be
/// exercised without pumping a widget tree.
(String label, Color background, Color foreground) missionStatusPresentation(
  AppLocalizations l10n,
  NokiColorScheme colors,
  DriverMissionResponseDtoStatus status,
) {
  return switch (status) {
    DriverMissionResponseDtoStatus.readyForDispatch => (l10n.missionStatusReadyForDispatch, colors.surfaceSubtle, colors.textMuted),
    DriverMissionResponseDtoStatus.assigned => (l10n.missionStatusAssigned, colors.infoSurface, colors.info),
    DriverMissionResponseDtoStatus.outForDelivery => (l10n.missionStatusOutForDelivery, colors.warningSurface, colors.warning),
    DriverMissionResponseDtoStatus.delivered => (l10n.missionStatusDelivered, colors.successSurface, colors.success),
    DriverMissionResponseDtoStatus.failed => (l10n.missionStatusFailed, colors.dangerSurface, colors.danger),
    DriverMissionResponseDtoStatus.cancelled => (l10n.missionStatusCancelled, colors.surfaceSubtle, colors.textMuted),
    DriverMissionResponseDtoStatus.unknown => (l10n.errorUnknown, colors.surfaceSubtle, colors.textMuted),
  };
}

String deliveryIncidentTypeLabel(AppLocalizations l10n, DeliveryIncidentResponseDtoType type) {
  return switch (type) {
    DeliveryIncidentResponseDtoType.delay => l10n.incidentTypeDelay,
    DeliveryIncidentResponseDtoType.vehicleIssue => l10n.incidentTypeVehicleIssue,
    DeliveryIncidentResponseDtoType.safety => l10n.incidentTypeSafety,
    DeliveryIncidentResponseDtoType.other => l10n.incidentTypeOther,
    DeliveryIncidentResponseDtoType.unknown => l10n.errorUnknown,
  };
}

String otpChallengeStatusLabel(AppLocalizations l10n, DeliveryHandoffOtpChallengeResponseDtoStatus status) {
  return switch (status) {
    DeliveryHandoffOtpChallengeResponseDtoStatus.pending => l10n.otpStatusPending,
    DeliveryHandoffOtpChallengeResponseDtoStatus.verified => l10n.otpStatusVerified,
    DeliveryHandoffOtpChallengeResponseDtoStatus.expired => l10n.otpStatusExpired,
    DeliveryHandoffOtpChallengeResponseDtoStatus.locked => l10n.otpStatusLocked,
    DeliveryHandoffOtpChallengeResponseDtoStatus.revoked => l10n.otpStatusRevoked,
    DeliveryHandoffOtpChallengeResponseDtoStatus.unknown => l10n.errorUnknown,
  };
}

(String label, Color background, Color foreground) deliveryIncidentStatusPresentation(
  AppLocalizations l10n,
  NokiColorScheme colors,
  DeliveryIncidentResponseDtoStatus status,
) {
  return switch (status) {
    DeliveryIncidentResponseDtoStatus.open => (l10n.incidentStatusOpen, colors.warningSurface, colors.warning),
    DeliveryIncidentResponseDtoStatus.resolved => (l10n.incidentStatusResolved, colors.successSurface, colors.success),
    DeliveryIncidentResponseDtoStatus.unknown => (l10n.errorUnknown, colors.surfaceSubtle, colors.textMuted),
  };
}
