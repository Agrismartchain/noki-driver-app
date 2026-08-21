import 'package:flutter/material.dart';

import '../../core/formatting/distance_duration_formatter.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../map/map_chrome.dart';
import 'navigation_route.dart';

/// Chips for the map screens' top status strip: ETA/distance readout when a
/// real route is available, or a degraded "route unavailable" chip plus a
/// retry control otherwise. Deliberately built only from existing
/// `map_chrome.dart` primitives (mandate: reuse, don't invent new visual
/// chrome) and returned as a flat list so callers fold them straight into
/// the `Wrap` that already holds the service-type/GPS chips - never as a
/// nested `Wrap`, so overflow wrapping stays predictable at narrow widths.
///
/// Deliberately shows only the *first* upcoming maneuver, not a live
/// turn-by-turn cursor that advances as the driver progresses along the
/// route - tracking "which maneuver is currently next" would require a
/// separate progress-matching engine that is out of scope for this pass.
List<Widget> navigationStatusChips(
  BuildContext context, {
  required NavigationRoute? route,
  required VoidCallback onRetry,
}) {
  if (route == null) return const [];
  final l10n = AppLocalizations.of(context);
  final colors = context.nokiColors;

  if (!route.isOk || !route.hasGeometry) {
    return [
      NokiMapStatusChip(
        label: l10n.navigationRouteUnavailable,
        icon: Icons.alt_route_outlined,
        backgroundColor: colors.warningSurface,
        foregroundColor: colors.warning,
      ),
      NokiMapControlButton(
        icon: Icons.refresh_rounded,
        tooltip: l10n.navigationRetryAction,
        onPressed: onRetry,
      ),
    ];
  }

  final formatter = DistanceDurationFormatter(
    Localizations.localeOf(context).toLanguageTag(),
  );
  final chips = <Widget>[];

  final durationSeconds = route.durationSeconds;
  if (durationSeconds != null) {
    chips.add(
      NokiMapStatusChip(
        label: l10n.navigationEtaLabel(formatter.eta(durationSeconds)),
        icon: Icons.schedule_rounded,
      ),
    );
  }

  final distanceMeters = route.distanceMeters;
  if (distanceMeters != null) {
    chips.add(
      NokiMapStatusChip(
        label: l10n.navigationDistanceRemainingLabel(
          formatter.distance(distanceMeters),
        ),
        icon: Icons.route_outlined,
      ),
    );
  }

  if (route.maneuvers.isNotEmpty) {
    final maneuver = route.maneuvers.first;
    final maneuverText = maneuver.instruction ?? maneuver.streetName;
    if (maneuverText != null) {
      chips.add(
        NokiMapStatusChip(
          label: l10n.navigationNextManeuverLabel(
            formatter.distance(maneuver.distanceMeters),
            maneuverText,
          ),
          icon: Icons.turn_slight_right_outlined,
          backgroundColor: colors.actionPrimary,
          foregroundColor: colors.actionPrimaryInk,
        ),
      );
    }
  }

  return chips;
}
