import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/features/mobility/mobility_status_presentation.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('legalRideTransitions', () {
    // Mirrors the server's RIDE_TRANSITIONS adjacency map exactly
    // (mobility.service.ts) - this is presentation-only gating, the server
    // remains authoritative, but the two must never drift apart or the UI
    // would offer an action the backend will reject.
    test('DRIVER_ASSIGNED can move to en route or be cancelled, nothing else', () {
      expect(
        legalRideTransitions(MobilityRideDetailDtoStatus.driverAssigned),
        [TransitionMobilityRideDtoStatus.driverEnRoute, TransitionMobilityRideDtoStatus.cancelled],
      );
    });

    test('DRIVER_EN_ROUTE can move to arrived or be cancelled', () {
      expect(
        legalRideTransitions(MobilityRideDetailDtoStatus.driverEnRoute),
        [TransitionMobilityRideDtoStatus.driverArrived, TransitionMobilityRideDtoStatus.cancelled],
      );
    });

    test('DRIVER_ARRIVED can move to in progress or be cancelled', () {
      expect(
        legalRideTransitions(MobilityRideDetailDtoStatus.driverArrived),
        [TransitionMobilityRideDtoStatus.inProgress, TransitionMobilityRideDtoStatus.cancelled],
      );
    });

    test('IN_PROGRESS can move to completed or be cancelled', () {
      expect(
        legalRideTransitions(MobilityRideDetailDtoStatus.inProgress),
        [TransitionMobilityRideDtoStatus.completed, TransitionMobilityRideDtoStatus.cancelled],
      );
    });

    test('COMPLETED and CANCELLED are terminal - no further action is ever offered', () {
      expect(legalRideTransitions(MobilityRideDetailDtoStatus.completed), isEmpty);
      expect(legalRideTransitions(MobilityRideDetailDtoStatus.cancelled), isEmpty);
    });

    test('an unrecognized status offers no action rather than guessing', () {
      expect(legalRideTransitions(MobilityRideDetailDtoStatus.unknown), isEmpty);
    });
  });

  group('rideStatusPresentation / serviceType labels', () {
    test('TAXI and TAXI_MOTO resolve to distinct labels', () {
      expect(
        rideServiceTypeLabel(l10n, MobilityRideDetailDtoServiceType.taxi),
        isNot(rideServiceTypeLabel(l10n, MobilityRideDetailDtoServiceType.taxiMoto)),
      );
    });

    test('every real ride status has a non-empty localized label', () {
      for (final status in MobilityRideDetailDtoStatus.values.where((s) => s != MobilityRideDetailDtoStatus.unknown)) {
        final (label, _, _) = rideStatusPresentation(l10n, NokiColors.light, status);
        expect(label, isNotEmpty);
      }
    });
  });
}
