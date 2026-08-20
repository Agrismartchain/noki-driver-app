import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/generated/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../ui/noki_state_views.dart';
import '../ui/noki_ui.dart';
import 'location_permission_state.dart';
import 'location_repository.dart';

/// Shown before any map/tracking UI. Handles every [LocationPermissionState]
/// without crashing or re-prompting a permanently-denied driver in a loop
/// (mandate §6). [builder] only ever runs once permission is genuinely
/// granted.
class LocationPermissionGate extends ConsumerStatefulWidget {
  const LocationPermissionGate({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  ConsumerState<LocationPermissionGate> createState() =>
      _LocationPermissionGateState();
}

class _LocationPermissionGateState
    extends ConsumerState<LocationPermissionGate> {
  bool _requesting = false;

  Future<void> _request() async {
    setState(() => _requesting = true);
    await ref.read(locationRepositoryProvider).requestPermission();
    ref.invalidate(locationPermissionStateProvider);
    if (mounted) setState(() => _requesting = false);
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(locationPermissionStateProvider);
    return asyncState.when(
      loading: () => const NokiScreenBackground(
        showMapGrid: true,
        child: NokiLoadingState(),
      ),
      error: (_, _) => _StateMessage(
        icon: Icons.location_disabled_outlined,
        message: AppLocalizations.of(context).locationErrorGeneric,
        actionLabel: AppLocalizations.of(context).actionRetry,
        onAction: () => ref.invalidate(locationPermissionStateProvider),
      ),
      data: (state) {
        switch (state) {
          case LocationPermissionState.granted:
            return widget.builder(context);
          case LocationPermissionState.serviceDisabled:
            return _StateMessage(
              icon: Icons.location_off_outlined,
              message: AppLocalizations.of(context).locationServiceDisabled,
              actionLabel: AppLocalizations.of(context).locationOpenSettings,
              onAction: () =>
                  ref.read(locationRepositoryProvider).openAppSettings(),
            );
          case LocationPermissionState.deniedForever:
            return _StateMessage(
              icon: Icons.location_off_outlined,
              message: AppLocalizations.of(context).locationDeniedForever,
              actionLabel: AppLocalizations.of(context).locationOpenSettings,
              onAction: () =>
                  ref.read(locationRepositoryProvider).openAppSettings(),
            );
          case LocationPermissionState.deniedOnce:
            return _StateMessage(
              icon: Icons.my_location_outlined,
              message: AppLocalizations.of(context).locationPermissionRationale,
              actionLabel: AppLocalizations.of(context).locationGrantAction,
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
      showMapGrid: true,
      child: Center(
        child: Padding(
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
