import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_localizer.dart';
import '../../core/location/location_permission_state.dart';
import '../../core/location/gps_publish_policy.dart';
import '../../core/location/gps_publisher.dart';
import '../../core/location/live_position_provider.dart';
import '../../core/location/location_permission_gate.dart';
import '../../core/location/location_repository.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/noki_finance.dart';
import '../../core/ui/noki_ui.dart';
import '../availability/availability_repository.dart';
import '../driver_context/driver_context_repository.dart';
import '../map/map_chrome.dart';
import '../map/map_point.dart';
import '../map/map_view.dart';
import '../work_feed/work_feed_repository.dart';
import 'mobility_repository.dart';
import 'mobility_status_presentation.dart';

/// Active-Ride map (mandate §13): driver position, pickup, destination,
/// current ride status and the next legal transition, on a live map. Ride
/// pickup/dropoff coordinates live directly on [MobilityRideDetailDto] - no
/// extra fetch needed, unlike Delivery's feed-item-only coordinates.
class MobilityRideMapScreen extends ConsumerStatefulWidget {
  const MobilityRideMapScreen({
    super.key,
    required this.rideId,
    required this.scope,
    this.tileProvider,
  });

  final String rideId;
  final DriverScope scope;

  /// Test-only override - see [NokiMapView.tileProvider].
  final TileProvider? tileProvider;

  @override
  ConsumerState<MobilityRideMapScreen> createState() =>
      _MobilityRideMapScreenState();
}

class _MobilityRideMapScreenState extends ConsumerState<MobilityRideMapScreen> {
  TransitionMobilityRideDtoStatus? _pendingTransition;
  AppFailure? _transitionFailure;

  // See the identical comment in DeliveryMissionMapScreen: `ref` is unusable
  // by the time State.dispose() runs, so the controller reference is
  // captured once instead of re-read.
  GpsPublisherController? _publisher;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final publisher = ref.read(gpsPublisherControllerProvider);
      publisher.updateContext(
        DriverTrackingContext(scope: widget.scope, activeRideId: widget.rideId),
      );
      _publisher = publisher;
    });
  }

  @override
  void dispose() {
    _publisher?.updateContext(DriverTrackingContext(scope: widget.scope));
    super.dispose();
  }

  Future<void> _transition(TransitionMobilityRideDtoStatus target) async {
    if (_pendingTransition != null) return;
    setState(() {
      _pendingTransition = target;
      _transitionFailure = null;
    });
    try {
      await ref
          .read(mobilityRepositoryProvider)
          .transitionRide(widget.rideId, target);
      ref.invalidate(rideByIdProvider(widget.rideId));
      ref.invalidate(availabilityProvider(widget.scope));
      ref.invalidate(currentRideProvider(widget.scope));
      ref.invalidate(workFeedProvider(widget.scope));
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _transitionFailure = failure);
    } finally {
      if (mounted) setState(() => _pendingTransition = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncRide = ref.watch(rideByIdProvider(widget.rideId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.mobilityMapTitle),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: LocationPermissionGate(
        // See the identical comment in DeliveryMissionMapScreen:
        // `livePositionProvider` must only be watched once permission is
        // already granted, or it lands in a permanent AsyncError before the
        // driver ever gets a chance to grant it (found live on-device).
        builder: (context) {
          final asyncPosition = ref.watch(livePositionProvider);
          final safeTop =
              MediaQuery.paddingOf(context).top + kToolbarHeight + 8;
          return Stack(
            children: [
              asyncRide.maybeWhen(
                data: (ride) => NokiMapView(
                  tileProvider: widget.tileProvider,
                  driverPosition: asyncPosition.whenOrNull(
                    data: (p) => MapPoint(p.latitude, p.longitude),
                  ),
                  pickup: MapPoint(
                    ride.pickupLatitude.toDouble(),
                    ride.pickupLongitude.toDouble(),
                  ),
                  dropoff: MapPoint(
                    ride.dropoffLatitude.toDouble(),
                    ride.dropoffLongitude.toDouble(),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: safeTop,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    asyncRide.maybeWhen(
                      data: (ride) => NokiMapStatusChip(
                        label: rideServiceTypeLabel(l10n, ride.serviceType),
                        icon:
                            ride.serviceType ==
                                MobilityRideDetailDtoServiceType.taxiMoto
                            ? Icons.moped_outlined
                            : Icons.local_taxi_outlined,
                        backgroundColor: context.nokiColors.actionPrimary,
                        foregroundColor: context.nokiColors.actionPrimaryInk,
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                    _GpsChip(asyncPosition: asyncPosition),
                  ],
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: asyncRide.maybeWhen(
                  data: (ride) => _BottomSheet(
                    ride: ride,
                    pendingTransition: _pendingTransition,
                    failure: _transitionFailure,
                    onTransition: _transition,
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({
    required this.ride,
    required this.pendingTransition,
    required this.failure,
    required this.onTransition,
  });

  final MobilityRideDetailDto ride;
  final TransitionMobilityRideDtoStatus? pendingTransition;
  final AppFailure? failure;
  final void Function(TransitionMobilityRideDtoStatus) onTransition;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final (label, background, foreground) = rideStatusPresentation(
      l10n,
      colors,
      ride.status,
    );
    final transitions = legalRideTransitions(ride.status);

    return NokiMapBottomPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NokiBadge(
                      label: label,
                      tone: NokiBadgeTone.neutral,
                      icon: Icons.adjust_rounded,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      ride.dropoffAddressSnapshot,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ride.reference,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              NokiMapStatusChip(
                label: rideServiceTypeLabel(l10n, ride.serviceType),
                icon:
                    ride.serviceType ==
                        MobilityRideDetailDtoServiceType.taxiMoto
                    ? Icons.moped_outlined
                    : Icons.local_taxi_outlined,
                backgroundColor: background,
                foregroundColor: foreground,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _RouteRow(
            icon: Icons.trip_origin,
            label: l10n.missionSectionPickup,
            value: ride.pickupAddressSnapshot,
            color: colors.textMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          _RouteRow(
            icon: Icons.place_outlined,
            label: l10n.missionSectionDropoff,
            value: ride.dropoffAddressSnapshot,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.lg),
          NokiFinanceCallout(
            label: l10n.financeEstimatedFareLabel,
            amount: ride.fareAmount.toString(),
            currencyCode: ride.currencyCode,
            caption: l10n.financeEstimatedFareHint,
            icon: Icons.payments_outlined,
          ),
          if (transitions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final target in transitions)
                  target == TransitionMobilityRideDtoStatus.cancelled
                      ? OutlinedButton(
                          onPressed: pendingTransition != null
                              ? null
                              : () => onTransition(target),
                          child: Text(rideTransitionActionLabel(l10n, target)),
                        )
                      : ElevatedButton(
                          onPressed: pendingTransition != null
                              ? null
                              : () => onTransition(target),
                          child: pendingTransition == target
                              ? SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.actionPrimaryInk,
                                  ),
                                )
                              : Text(rideTransitionActionLabel(l10n, target)),
                        ),
              ],
            ),
          ],
          if (failure != null) ...[
            const SizedBox(height: AppSpacing.md),
            NokiOperationalBanner(
              icon: Icons.warning_amber_rounded,
              message: localizeFailure(context, failure!),
              tone: NokiBadgeTone.danger,
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: color),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GpsChip extends ConsumerWidget {
  const _GpsChip({required this.asyncPosition});

  final AsyncValue<Object?> asyncPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final permission = ref.watch(locationPermissionStateProvider);
    final colors = context.nokiColors;

    if (permission.valueOrNull == LocationPermissionState.serviceDisabled) {
      return NokiMapStatusChip(
        label: l10n.mapGpsDisabled,
        icon: Icons.location_off_outlined,
        backgroundColor: colors.warningSurface,
        foregroundColor: colors.warning,
      );
    }

    return asyncPosition.when(
      data: (_) => NokiMapStatusChip(
        label: l10n.mapGpsLive,
        icon: Icons.my_location_rounded,
      ),
      error: (_, _) => NokiMapStatusChip(
        label: l10n.mapGpsUnavailable,
        icon: Icons.gps_off_rounded,
        backgroundColor: colors.dangerSurface,
        foregroundColor: colors.danger,
      ),
      loading: () => NokiMapStatusChip(
        label: l10n.mapGpsLocating,
        icon: Icons.gps_fixed_outlined,
      ),
    );
  }
}
