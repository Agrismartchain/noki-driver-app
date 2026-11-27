import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/i18n/generated/app_localizations.dart';
import '../core/location/gps_publisher.dart';
import '../core/location/live_position_provider.dart';
import '../core/location/location_repository.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/motion.dart';
import '../features/auth/auth_providers.dart';
import '../features/driver_context/driver_context_repository.dart';
import '../features/driver_context/home_screen.dart';
import '../features/earnings/earnings_screen.dart';
import '../features/mobility/mobility_offer_poller.dart';
import '../features/settings/settings_screen.dart';
import '../features/work_feed/work_feed_screen.dart';

/// Bottom-navigation shell for the four operational sections: Home, Work,
/// Earnings and Profile. Uses standard (non-extended) Scaffold body layout so
/// tab content always terminates cleanly above the navigation bar and system
/// insets.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // GPS publishing and Mobility offer polling are foreground-only. When the
  // driver returns to the app (e.g. after toggling GPS or location permission
  // in Android Settings), we also re-read the location permission/service
  // state and live position stream so the Home map and GPS banner refresh
  // immediately.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final publisher = ref.read(gpsPublisherControllerProvider);
    final offerPoller = ref.read(mobilityOfferPollerControllerProvider);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.invalidate(locationPermissionStateProvider);
        ref.invalidate(livePositionProvider);
        publisher.resumeForForeground();
        offerPoller.resumeForForeground();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        publisher.pauseForBackground();
        offerPoller.pauseForBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final driverContext = ref.watch(authControllerProvider).driverContext;
    final scope = driverContext == null ? null : activeScopeFrom(driverContext);

    final tabs = [
      HomeScreen(onOpenWork: () => setState(() => _index = 1)),
      if (scope != null)
        WorkFeedScreen(scope: scope)
      else
        const SizedBox.shrink(),
      if (scope != null)
        EarningsScreen(scope: scope)
      else
        const SizedBox.shrink(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                _ShellDestination(
                  selected: _index == 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: l10n.navHome,
                  onTap: () => setState(() => _index = 0),
                ),
                _ShellDestination(
                  selected: _index == 1,
                  icon: Icons.work_outline,
                  selectedIcon: Icons.work_rounded,
                  label: l10n.navWork,
                  onTap: () => setState(() => _index = 1),
                ),
                _ShellDestination(
                  selected: _index == 2,
                  icon: Icons.account_balance_wallet_outlined,
                  selectedIcon: Icons.account_balance_wallet_rounded,
                  label: l10n.navEarnings,
                  onTap: () => setState(() => _index = 2),
                ),
                _ShellDestination(
                  selected: _index == 3,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person_rounded,
                  label: l10n.navProfile,
                  onTap: () => setState(() => _index = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellDestination extends StatelessWidget {
  const _ShellDestination({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final activeForeground = isDark
        ? colors.actionPrimary
        : colors.actionPrimaryInk;
    final activePillColor = isDark
        ? colors.surfaceSelected
        : colors.actionPrimary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: NokiMotion.duration(
                    context,
                    const Duration(milliseconds: 180),
                  ),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? activePillColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Icon(
                    selected ? selectedIcon : icon,
                    color: selected ? activeForeground : colors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: selected ? colors.textPrimary : colors.textMuted,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
