import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/i18n/generated/app_localizations.dart';
import '../features/auth/auth_providers.dart';
import '../features/driver_context/driver_context_repository.dart';
import '../features/driver_context/home_screen.dart';
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

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final driverContext = ref.watch(authControllerProvider).driverContext;
    final scope = driverContext == null ? null : activeScopeFrom(driverContext);

    final tabs = [
      HomeScreen(onOpenWork: () => setState(() => _index = 1)),
      if (scope != null) WorkFeedScreen(scope: scope) else const SizedBox.shrink(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l10n.navHome),
          NavigationDestination(icon: const Icon(Icons.work_outline), selectedIcon: const Icon(Icons.work), label: l10n.navWork),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: l10n.navProfile),
        ],
      ),
    );
  }
}
