import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/error_view.dart';
import '../../core/errors/failure_localizer.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../driver_context/driver_context_repository.dart';
import 'mobility_repository.dart';
import 'mobility_ride_map_screen.dart';
import 'mobility_status_presentation.dart';

/// Current/active ride presentation and transitions. Only the transitions
/// [legalRideTransitions] says are legal from the ride's current status are
/// ever rendered as buttons, and every tap awaits the server's response
/// before the ride is refreshed - no optimistic status flip (mandate §15).
class MobilityRideScreen extends ConsumerStatefulWidget {
  const MobilityRideScreen({super.key, required this.rideId, required this.scope});

  final String rideId;
  final DriverScope scope;

  @override
  ConsumerState<MobilityRideScreen> createState() => _MobilityRideScreenState();
}

class _MobilityRideScreenState extends ConsumerState<MobilityRideScreen> {
  TransitionMobilityRideDtoStatus? _pendingTransition;
  AppFailure? _transitionFailure;

  Future<void> _transition(TransitionMobilityRideDtoStatus target) async {
    if (_pendingTransition != null) return;
    setState(() {
      _pendingTransition = target;
      _transitionFailure = null;
    });
    try {
      await ref.read(mobilityRepositoryProvider).transitionRide(widget.rideId, target);
      ref.invalidate(rideByIdProvider(widget.rideId));
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _transitionFailure = failure);
    } finally {
      if (mounted) setState(() => _pendingTransition = null);
    }
  }

  Future<void> _navigate(num latitude, num longitude) async {
    await launchUrl(Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncRide = ref.watch(rideByIdProvider(widget.rideId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mobilityRideDetailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: l10n.mobilityMapTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MobilityRideMapScreen(rideId: widget.rideId, scope: widget.scope)),
            ),
          ),
        ],
      ),
      body: asyncRide.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          failure: error is AppFailure ? error : const AppFailure(AppFailureType.unknown),
          onRetry: () => ref.invalidate(rideByIdProvider(widget.rideId)),
        ),
        data: _buildContent,
      ),
    );
  }

  Widget _buildContent(MobilityRideDetailDto ride) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final transitions = legalRideTransitions(ride.status);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(rideByIdProvider(widget.rideId)),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              Icon(
                ride.serviceType == MobilityRideDetailDtoServiceType.taxiMoto ? Icons.moped_outlined : Icons.local_taxi_outlined,
                color: colors.actionPrimary,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rideServiceTypeLabel(l10n, ride.serviceType), style: Theme.of(context).textTheme.titleLarge),
                    Text(ride.reference, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textMuted)),
                  ],
                ),
              ),
              _StatusBadge(status: ride.status),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoutePoint(
                    icon: Icons.trip_origin,
                    label: l10n.missionSectionPickup,
                    address: ride.pickupAddressSnapshot,
                    onNavigate: () => _navigate(ride.pickupLatitude, ride.pickupLongitude),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _RoutePoint(
                    icon: Icons.place_outlined,
                    label: l10n.missionSectionDropoff,
                    address: ride.dropoffAddressSnapshot,
                    onNavigate: () => _navigate(ride.dropoffLatitude, ride.dropoffLongitude),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.mobilityFareLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.textMuted)),
                  Text('${ride.fareAmount} ${ride.currencyCode}', style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
          ),
          if (ride.timeline.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.mobilityTimelineTitle, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    for (final entry in ride.timeline)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          entry.message ?? '${entry.fromStatus ?? '·'} -> ${entry.toStatus ?? '·'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (transitions.isEmpty)
            Text(l10n.mobilityRideNoActionsAvailable, style: TextStyle(color: colors.textMuted))
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final target in transitions)
                  target == TransitionMobilityRideDtoStatus.cancelled
                      ? OutlinedButton(
                          onPressed: _pendingTransition != null ? null : () => _transition(target),
                          child: Text(rideTransitionActionLabel(l10n, target)),
                        )
                      : ElevatedButton(
                          onPressed: _pendingTransition != null ? null : () => _transition(target),
                          child: _pendingTransition == target
                              ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colors.actionPrimaryInk))
                              : Text(rideTransitionActionLabel(l10n, target)),
                        ),
              ],
            ),
          if (_transitionFailure != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(localizeFailure(context, _transitionFailure!), style: TextStyle(color: colors.danger)),
          ],
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({required this.icon, required this.label, required this.address, this.onNavigate});

  final IconData icon;
  final String label;
  final String address;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.textMuted)),
              Text(address, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (onNavigate != null)
          IconButton(
            onPressed: onNavigate,
            icon: const Icon(Icons.navigation_outlined),
            tooltip: l10n.missionNavigateAction,
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final MobilityRideDetailDtoStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final (label, background, foreground) = rideStatusPresentation(l10n, colors, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground)),
    );
  }
}
