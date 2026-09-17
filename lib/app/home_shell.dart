import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/i18n/generated/app_localizations.dart';
import '../core/location/gps_publisher.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/auth_providers.dart';
import '../features/driver_context/driver_context_repository.dart';
import '../features/driver_context/home_screen.dart';
import '../features/mobility/mobility_offer_poller.dart';
import '../features/settings/settings_screen.dart';
import '../features/work_feed/work_feed_screen.dart';

/// Bottom-navigation shell for the three sections wired up in
/// DRIVER-APP-01: Home, Work and Profile. "Activity" (trip/earnings
/// history) is intentionally not shown as a fourth tab yet - no backend
/// endpoint backs it in this phase, and DRIVER-APP-01 section 19 forbids
/// shipping a "coming soon" placeholder in an operational product. It will
/// be added once its data source exists.
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

  // GPS publishing is foreground-only this phase (mandate §10/§35) - no
  // duplicate stream survives a background/foreground cycle, and nothing is
  // sent while the app isn't visible to the driver. Mobility offer polling
  // (DRIVER-APP offer auto-discovery) follows the exact same rule - this is
  // the one place that pauses/resumes both.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final publisher = ref.read(gpsPublisherControllerProvider);
    final offerPoller = ref.read(mobilityOfferPollerControllerProvider);
    switch (state) {
      case AppLifecycleState.resumed:
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
    final driverContext = ref.watch(authControllerProvider).driverContext;
    final scope = driverContext == null ? null : activeScopeFrom(driverContext);

    final tabs = [
      HomeScreen(onOpenWork: () => setState(() => _index = 1)),
      if (scope != null)
        WorkFeedScreen(scope: scope)
      else
        const SizedBox.shrink(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      extendBody: true,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: context.nokiColors.chromeSurface.withValues(alpha: 0.94),
          border: Border(
            top: BorderSide(color: context.nokiColors.chromeBorder),
          ),
          boxShadow: [
            BoxShadow(
              color: context.nokiColors.shadowColor.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
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
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person_rounded,
                  label: l10n.navProfile,
                  onTap: () => setState(() => _index = 2),
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
    final textTheme = Theme.of(context).textTheme;

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
                Icon(
                  selected ? selectedIcon : icon,
                  color: selected ? colors.actionPrimary : colors.textMuted,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: selected ? colors.actionPrimary : colors.textMuted,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: selected ? 8 : 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: selected ? colors.actionPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.full),
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
