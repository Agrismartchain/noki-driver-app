import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/features/delivery/delivery_status_presentation.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('missionStatusPresentation', () {
    test('every real backend status resolves to a distinct, non-empty label', () {
      final statuses = DriverMissionResponseDtoStatus.values.where((s) => s != DriverMissionResponseDtoStatus.unknown);
      final labels = <String>{};
      for (final status in statuses) {
        final (label, _, _) = missionStatusPresentation(l10n, NokiColors.light, status);
        expect(label, isNotEmpty);
        labels.add(label);
      }
      expect(labels, hasLength(statuses.length), reason: 'no two distinct statuses should collapse to the same label');
    });

    test('an unrecognized backend status maps to the generic unknown label, never crashes', () {
      final status = DriverMissionResponseDtoStatus.fromJson('SOMETHING_NEW');
      final (label, _, _) = missionStatusPresentation(l10n, NokiColors.light, status);
      expect(status, DriverMissionResponseDtoStatus.unknown);
      expect(label, l10n.errorUnknown);
    });
  });

  group('deliveryIncidentTypeLabel / deliveryIncidentStatusPresentation', () {
    test('every real incident type has a localized label', () {
      for (final type in DeliveryIncidentResponseDtoType.values.where((t) => t != DeliveryIncidentResponseDtoType.unknown)) {
        expect(deliveryIncidentTypeLabel(l10n, type), isNotEmpty);
      }
    });

    test('OPEN and RESOLVED map to different semantic colors', () {
      final (openLabel, openBg, _) = deliveryIncidentStatusPresentation(l10n, NokiColors.light, DeliveryIncidentResponseDtoStatus.open);
      final (resolvedLabel, resolvedBg, _) =
          deliveryIncidentStatusPresentation(l10n, NokiColors.light, DeliveryIncidentResponseDtoStatus.resolved);
      expect(openLabel, isNot(resolvedLabel));
      expect(openBg, isNot(resolvedBg));
    });
  });
}
