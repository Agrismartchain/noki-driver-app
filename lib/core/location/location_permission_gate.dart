import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/generated/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../ui/noki_state_views.dart';
import '../ui/noki_ui.dart';
import 'live_position_provider.dart';
import 'location_permission_state.dart';
import 'location_repository.dart';

/// Shown before any map/tracking UI. Handles every [LocationPermissionState]
/// without crashing or re-prompting a permanently-denied driver in a loop
/// (mandate §6). Re-checks permission and GPS state automatically whenever
/// the app returns to foreground (e.g. after opening device Settings).
class LocationPermissionGate extends ConsumerStatefulWidget {
  const LocationPermissionGate({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  ConsumerState<LocationPermissionGate> createState() =>
      _LocationPermissionGateState();
}

class _LocationPermissionGateState extends ConsumerState<LocationPermissionGate>
    with WidgetsBindingObserver {
  bool _requesting = false;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(locationPermissionStateProvider);
      ref.invalidate(livePositionProvider);
    }
  }

  Future<void> _request() async {
    setState(() => _requesting = true);
    await ref.read(locationRepositoryProvider).requestPermission();
    ref.invalidate(locationPermissionStateProvider);
    ref.invalidate(livePositionProvider);
    if (mounted) setState(() => _requesting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncState = ref.watch(locationPermissionStateProvider);
    return asyncState.when(
      loading: () => const NokiScreenBackground(child: NokiLoadingState()),
      error: (_, _) => _StateMessage(
        icon: Icons.location_disabled_outlined,
        message: l10n.locationErrorGeneric,
        actionLabel: l10n.actionRetry,
        onAction: () => ref.invalidate(locationPermissionStateProvider),
      ),
      data: (state) {
        switch (state) {
          case LocationPermissionState.granted:
            return widget.builder(context);
          case LocationPermissionState.serviceDisabled:
            return _StateMessage(
              icon: Icons.location_off_outlined,
              message: l10n.locationServiceDisabled,
              actionLabel: l10n.locationOpenLocationSettings,
              onAction: () =>
                  ref.read(locationRepositoryProvider).openLocationSettings(),
            );
          case LocationPermissionState.deniedForever:
            return _StateMessage(
              icon: Icons.location_off_outlined,
              message: l10n.locationDeniedForever,
              actionLabel: l10n.locationOpenSettings,
              onAction: () =>
                  ref.read(locationRepositoryProvider).openAppSettings(),
            );
          case LocationPermissionState.deniedOnce:
            return _StateMessage(
              icon: Icons.my_location_outlined,
              message: l10n.locationPermissionRationale,
              actionLabel: l10n.locationGrantAction,
              onAction: _requesting ? null : _request,
              loading: _requesting,
            );
        }
      },
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.loading = false,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    return NokiScreenBackground(
      safeTop: true,
      safeBottom: true,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: NokiSurfaceCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NokiBadge(
                  label: 'GPS',
                  tone: NokiBadgeTone.offline,
                  icon: icon,
                ),
                const SizedBox(height: AppSpacing.lg),
                Icon(icon, size: 44, color: colors.textMuted),
                const SizedBox(height: AppSpacing.md),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: onAction,
                  child: loading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.actionPrimaryInk,
                          ),
                        )
                      : Text(actionLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
