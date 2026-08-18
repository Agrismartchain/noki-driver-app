import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/generated/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'connectivity_status.dart';

/// Thin banner shown above the current screen whenever the device reports
/// no network interface up. Never blocks the UI - screens still render
/// whatever data they already have.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(networkStatusProvider).valueOrNull ?? NetworkStatus.unknown;
    if (status != NetworkStatus.offline) return const SizedBox.shrink();

    final colors = context.nokiColors;
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      color: colors.warningSurface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.wifi_off, size: 16, color: colors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.offlineBannerMessage,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
