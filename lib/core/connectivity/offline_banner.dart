import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/map/map_chrome.dart';
import '../i18n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../ui/noki_ui.dart';
import 'connectivity_status.dart';

/// Thin banner shown above the current screen whenever the device reports
/// no network interface up. Never blocks the UI - screens still render
/// whatever data they already have.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        ref.watch(networkStatusProvider).valueOrNull ?? NetworkStatus.unknown;
    if (status != NetworkStatus.offline) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: NokiOperationalBanner(
        icon: Icons.wifi_off,
        message: l10n.offlineBannerMessage,
        tone: NokiBadgeTone.offline,
      ),
    );
  }
}

/// Compact counterpart to [OfflineBanner] for the map screens' floating
/// top status strip (`DeliveryMissionMapScreen`/`MobilityRideMapScreen`),
/// which has no room for a full-width banner. Folds into the same `Wrap`
/// as the GPS/navigation chips - see `navigation_status_chips.dart`'s doc
/// comment on why that's a flat chip list, not a full-width widget.
///
/// A driver mid-navigation losing network is exactly the "recovery after
/// network loss" scenario the mission's QA pass calls out - until now the
/// map screens had no connectivity signal at all, only `OfflineBanner` on
/// Home.
class NetworkStatusChip extends ConsumerWidget {
  const NetworkStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        ref.watch(networkStatusProvider).valueOrNull ?? NetworkStatus.unknown;
    if (status != NetworkStatus.offline) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    return NokiMapStatusChip(
      label: l10n.offlineBannerMessage,
      icon: Icons.wifi_off,
      backgroundColor: colors.chromeSurface,
      foregroundColor: colors.chromeInk,
    );
  }
}
