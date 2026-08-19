import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_localizer.dart';
import '../../core/location/gps_publish_policy.dart';
import '../../core/location/gps_publisher.dart';
import '../../core/location/live_position_provider.dart';
import '../../core/location/location_permission_gate.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../driver_context/driver_context_repository.dart';
import '../map/map_point.dart';
import '../map/map_view.dart';
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
      appBar: AppBar(title: Text(l10n.mobilityMapTitle)),
      body: LocationPermissionGate(
        // See the identical comment in DeliveryMissionMapScreen:
        // `livePositionProvider` must only be watched once permission is
        // already granted, or it lands in a permanent AsyncError before the
        // driver ever gets a chance to grant it (found live on-device).
        builder: (context) {
          final asyncPosition = ref.watch(livePositionProvider);
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: foreground),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    rideServiceTypeLabel(l10n, ride.serviceType),
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (transitions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
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
                            child: Text(
                              rideTransitionActionLabel(l10n, target),
                            ),
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
              const SizedBox(height: AppSpacing.sm),
              Text(
                localizeFailure(context, failure!),
                style: TextStyle(color: colors.danger),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
