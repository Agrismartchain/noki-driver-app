import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/generated/app_localizations.dart';
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
