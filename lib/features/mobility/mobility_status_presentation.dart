import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';

/// The real backend ride state machine (`RIDE_TRANSITIONS` in
/// `mobility.service.ts`), mirrored client-side for presentation only - the
/// server remains authoritative and re-validates every transition. Pure
/// function so it is directly unit-testable (mandate §46 "legal action
/// availability").
List<TransitionMobilityRideDtoStatus> legalRideTransitions(
  MobilityRideDetailDtoStatus current,
) {
  switch (current) {
    case MobilityRideDetailDtoStatus.driverAssigned:
      return const [
        TransitionMobilityRideDtoStatus.driverEnRoute,
        TransitionMobilityRideDtoStatus.cancelled,
      ];
    case MobilityRideDetailDtoStatus.driverEnRoute:
      return const [
        TransitionMobilityRideDtoStatus.driverArrived,
        TransitionMobilityRideDtoStatus.cancelled,
      ];
    case MobilityRideDetailDtoStatus.driverArrived:
      return const [
        TransitionMobilityRideDtoStatus.inProgress,
        TransitionMobilityRideDtoStatus.cancelled,
      ];
    case MobilityRideDetailDtoStatus.inProgress:
      return const [
        TransitionMobilityRideDtoStatus.completed,
        TransitionMobilityRideDtoStatus.cancelled,
      ];
    case MobilityRideDetailDtoStatus.completed:
    case MobilityRideDetailDtoStatus.cancelled:
    case MobilityRideDetailDtoStatus.unknown:
      return const [];
  }
}

(String label, Color background, Color foreground) rideStatusPresentation(
  AppLocalizations l10n,
  NokiColorScheme colors,
  MobilityRideDetailDtoStatus status,
) {
  return switch (status) {
    MobilityRideDetailDtoStatus.driverAssigned => (
      l10n.rideStatusDriverAssigned,
      colors.infoSurface,
      colors.info,
    ),
    MobilityRideDetailDtoStatus.driverEnRoute => (
      l10n.rideStatusDriverEnRoute,
      colors.infoSurface,
      colors.info,
    ),
    MobilityRideDetailDtoStatus.driverArrived => (
      l10n.rideStatusDriverArrived,
      colors.warningSurface,
      colors.warning,
    ),
    MobilityRideDetailDtoStatus.inProgress => (
      l10n.rideStatusInProgress,
      colors.warningSurface,
      colors.warning,
    ),
    MobilityRideDetailDtoStatus.completed => (
      l10n.rideStatusCompleted,
      colors.successSurface,
      colors.success,
    ),
    MobilityRideDetailDtoStatus.cancelled => (
      l10n.rideStatusCancelled,
      colors.surfaceSubtle,
      colors.textMuted,
    ),
    MobilityRideDetailDtoStatus.unknown => (
      l10n.errorUnknown,
      colors.surfaceSubtle,
      colors.textMuted,
    ),
  };
}

String rideTransitionActionLabel(
  AppLocalizations l10n,
  TransitionMobilityRideDtoStatus target,
) {
  return switch (target) {
    TransitionMobilityRideDtoStatus.driverEnRoute => l10n.rideActionMarkEnRoute,
    TransitionMobilityRideDtoStatus.driverArrived => l10n.rideActionMarkArrived,
    TransitionMobilityRideDtoStatus.inProgress => l10n.rideActionStart,
    TransitionMobilityRideDtoStatus.completed => l10n.rideActionComplete,
    TransitionMobilityRideDtoStatus.cancelled => l10n.rideActionCancel,
    TransitionMobilityRideDtoStatus.driverAssigned ||
    TransitionMobilityRideDtoStatus.unknown => l10n.errorUnknown,
  };
}

String rideServiceTypeLabel(
  AppLocalizations l10n,
  MobilityRideDetailDtoServiceType serviceType,
) {
  return switch (serviceType) {
    MobilityRideDetailDtoServiceType.taxi => l10n.serviceTypeTaxi,
    MobilityRideDetailDtoServiceType.taxiMoto => l10n.serviceTypeTaxiMoto,
    MobilityRideDetailDtoServiceType.courier => l10n.serviceTypeCourier,
    MobilityRideDetailDtoServiceType.cargo => l10n.serviceTypeCargo,
    MobilityRideDetailDtoServiceType.unknown => l10n.errorUnknown,
  };
}

String offerServiceTypeLabel(
  AppLocalizations l10n,
  DriverMobilityOfferDtoServiceType serviceType,
) {
  return switch (serviceType) {
    DriverMobilityOfferDtoServiceType.taxi => l10n.serviceTypeTaxi,
    DriverMobilityOfferDtoServiceType.taxiMoto => l10n.serviceTypeTaxiMoto,
    DriverMobilityOfferDtoServiceType.courier => l10n.serviceTypeCourier,
    DriverMobilityOfferDtoServiceType.cargo => l10n.serviceTypeCargo,
    DriverMobilityOfferDtoServiceType.unknown => l10n.errorUnknown,
  };
}

String workFeedServiceTypeLabel(
  AppLocalizations l10n,
  DriverWorkFeedItemDtoServiceType serviceType,
) {
  return switch (serviceType) {
    DriverWorkFeedItemDtoServiceType.delivery => l10n.workFeedTypeDelivery,
    DriverWorkFeedItemDtoServiceType.taxi => l10n.serviceTypeTaxi,
    DriverWorkFeedItemDtoServiceType.taxiMoto => l10n.serviceTypeTaxiMoto,
    DriverWorkFeedItemDtoServiceType.courier => l10n.serviceTypeCourier,
    DriverWorkFeedItemDtoServiceType.cargo => l10n.serviceTypeCargo,
    DriverWorkFeedItemDtoServiceType.unknown => l10n.errorUnknown,
  };
}

/// Shared active-ride icon by service type - kept alongside
/// [rideServiceTypeLabel] so every screen that renders a ride (ride screen,
/// in-app map, header) shows the same glyph for the same service.
IconData rideServiceTypeIcon(MobilityRideDetailDtoServiceType serviceType) {
  switch (serviceType) {
    case MobilityRideDetailDtoServiceType.taxiMoto:
      return Icons.moped_outlined;
    case MobilityRideDetailDtoServiceType.cargo:
      return Icons.local_shipping_outlined;
    case MobilityRideDetailDtoServiceType.courier:
      return Icons.inventory_2_outlined;
    case MobilityRideDetailDtoServiceType.taxi:
    case MobilityRideDetailDtoServiceType.unknown:
      return Icons.local_taxi_outlined;
  }
}

String mobilityIncidentTypeLabel(
  AppLocalizations l10n,
  MobilityIncidentDtoType type,
) {
  return switch (type) {
    MobilityIncidentDtoType.ride => l10n.mobilityIncidentTypeRide,
    MobilityIncidentDtoType.driver => l10n.mobilityIncidentTypeDriver,
    MobilityIncidentDtoType.vehicle => l10n.incidentTypeVehicleIssue,
    MobilityIncidentDtoType.customerComplaint =>
      l10n.mobilityIncidentTypeCustomerComplaint,
    MobilityIncidentDtoType.safety => l10n.incidentTypeSafety,
    MobilityIncidentDtoType.other => l10n.incidentTypeOther,
    MobilityIncidentDtoType.unknown => l10n.errorUnknown,
  };
}

(String label, Color background, Color foreground)
mobilityIncidentStatusPresentation(
  AppLocalizations l10n,
  NokiColorScheme colors,
  MobilityIncidentDtoStatus status,
) {
  return switch (status) {
    MobilityIncidentDtoStatus.open => (
      l10n.incidentStatusOpen,
      colors.warningSurface,
      colors.warning,
    ),
    MobilityIncidentDtoStatus.inProgress => (
      l10n.mobilityIncidentStatusInProgress,
      colors.infoSurface,
      colors.info,
    ),
    MobilityIncidentDtoStatus.resolved => (
      l10n.incidentStatusResolved,
      colors.successSurface,
      colors.success,
    ),
    MobilityIncidentDtoStatus.dismissed => (
      l10n.mobilityIncidentStatusDismissed,
      colors.surfaceSubtle,
      colors.textMuted,
    ),
    MobilityIncidentDtoStatus.unknown => (
      l10n.errorUnknown,
      colors.surfaceSubtle,
      colors.textMuted,
    ),
  };
}
