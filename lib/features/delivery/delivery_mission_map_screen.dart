import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/generated/driver_models.generated.dart';
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
import '../driver_context/driver_context_repository.dart';
import '../map/map_chrome.dart';
import '../map/map_point.dart';
import '../map/map_view.dart';
import '../navigation/navigation_route_controller.dart';
import '../navigation/navigation_status_chips.dart';
import 'delivery_repository.dart';
import 'delivery_status_presentation.dart';

/// Active-Delivery map (mandate §12): driver position, pickup, drop-off,
/// current status and the mission's next legal action, on top of a live map.
/// Pickup/dropoff coordinates only exist on the originating Work Feed item
/// (see `delivery_mission_detail_screen.dart`'s header comment) - [feedItem]
/// carries them here the same way.
class DeliveryMissionMapScreen extends ConsumerStatefulWidget {
  const DeliveryMissionMapScreen({
    super.key,
    required this.missionId,
    required this.scope,
    this.feedItem,
    this.tileProvider,
  });

  final String missionId;
  final DriverScope scope;
  final DriverWorkFeedItemDto? feedItem;

  /// Test-only override - see [NokiMapView.tileProvider].
  final TileProvider? tileProvider;

  @override
  ConsumerState<DeliveryMissionMapScreen> createState() =>
      _DeliveryMissionMapScreenState();
}

class _DeliveryMissionMapScreenState
    extends ConsumerState<DeliveryMissionMapScreen> {
  // Captured once in initState, not re-read via `ref` in dispose(): by the
  // time State.dispose() runs, the ConsumerState's `ref` is already
  // unusable (Riverpod asserts `context.mounted` on every read/watch).
  // GpsPublisherController itself is a plain, long-lived object independent
  // of this widget's lifecycle, so calling a method on the captured
  // reference directly is safe.
  GpsPublisherController? _publisher;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final publisher = ref.read(gpsPublisherControllerProvider);
      publisher.updateContext(
        DriverTrackingContext(
          scope: widget.scope,
          activeMissionId: widget.missionId,
        ),
      );
      _publisher = publisher;
    });
  }

  @override
  void dispose() {
    // Leaving the active-work screen: fall back to idle tracking under the
    // driver's last-known availability rather than an active-work cadence
    // that no longer applies.
    _publisher?.updateContext(DriverTrackingContext(scope: widget.scope));
    super.dispose();
  }

  Future<void> _call(String phone) async {
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncMission = ref.watch(missionDetailProvider(widget.missionId));

    final pickupCoords = widget.feedItem?.pickup;
    final dropoffCoords = widget.feedItem?.dropoff;
    final pickup =
        pickupCoords?.latitude != null && pickupCoords?.longitude != null
        ? MapPoint(
            pickupCoords!.latitude!.toDouble(),
            pickupCoords.longitude!.toDouble(),
          )
        : null;
    final dropoff =
        dropoffCoords?.latitude != null && dropoffCoords?.longitude != null
        ? MapPoint(
            dropoffCoords!.latitude!.toDouble(),
            dropoffCoords.longitude!.toDouble(),
          )
        : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.missionMapTitle),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: LocationPermissionGate(
        // `livePositionProvider` is only watched once permission is
        // already confirmed granted (i.e. inside this builder), not at the
        // top of build() - watching it earlier would start the position
        // stream before permission exists, land it in a permanent
        // AsyncError, and (since this same widget keeps watching it across
        // the permission-granted transition) never retry even after the
        // driver grants access. Caught live on-device (mandate §57).
        builder: (context) {
          final asyncPosition = ref.watch(livePositionProvider);
          final safeTop =
              MediaQuery.paddingOf(context).top + kToolbarHeight + 8;

          // Pre-pickup (package not yet with the driver) routes to pickup;
          // once out-for-delivery (package handed to the driver) it routes
          // to drop-off - see the class doc and the mission report for the
          // evidence behind this split. Terminal statuses need no route.
          final mission = asyncMission.valueOrNull;
          final destination = mission == null
              ? null
              : _deliveryNavigationDestination(
                  mission.status,
                  pickup: pickup,
                  dropoff: dropoff,
                );
          final target = destination == null
              ? null
              : NavigationTarget(
                  destination: destination,
                  serviceType: ComputeDriverRouteRequestDtoServiceType.delivery,
                );
          final navState = target == null
              ? null
              : ref.watch(navigationRouteControllerProvider(target));

          // Forwards the current driver position to the controller after
          // every frame; the controller itself applies the deviation +
          // cooldown gate (mandate §40/§41), so calling this on every
          // rebuild is harmless - it fetches once immediately (screen
          // entry) and then only actually recomputes once both thresholds
          // are satisfied.
          final currentPosition = asyncPosition.valueOrNull;
          if (target != null && currentPosition != null) {
            final origin = MapPoint(
              currentPosition.latitude,
              currentPosition.longitude,
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ref
                  .read(navigationRouteControllerProvider(target).notifier)
                  .updateOrigin(origin);
            });
          }

          return Stack(
            children: [
              NokiMapView(
                tileProvider: widget.tileProvider,
                driverPosition: asyncPosition.whenOrNull(
                  data: (p) => MapPoint(p.latitude, p.longitude),
                ),
                pickup: pickup,
                dropoff: dropoff,
                routeGeometry:
                    navState?.route?.isOk == true &&
                        navState?.route?.hasGeometry == true
                    ? navState!.route!.geometry
                    : null,
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: safeTop,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    NokiMapStatusChip(
                      label: l10n.workFeedTypeDelivery,
                      icon: Icons.local_shipping_outlined,
                      backgroundColor: context.nokiColors.actionPrimary,
                      foregroundColor: context.nokiColors.actionPrimaryInk,
                    ),
                    _GpsChip(asyncPosition: asyncPosition),
                    ...navigationStatusChips(
                      context,
                      route: navState?.route,
                      onRetry: () {
                        final position = asyncPosition.valueOrNull;
                        if (position == null || target == null) return;
                        ref
                            .read(
                              navigationRouteControllerProvider(target)
                                  .notifier,
                            )
                            .retry(
                              MapPoint(position.latitude, position.longitude),
                            );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: asyncMission.maybeWhen(
                  data: (mission) => _BottomSheet(
                    mission: mission,
                    feedItem: widget.feedItem,
                    onOpenDetails: () => Navigator.of(context).pop(),
                    onCall: mission.customerPhone == null
                        ? null
                        : () => _call(mission.customerPhone!),
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
    required this.mission,
    required this.feedItem,
    required this.onOpenDetails,
    this.onCall,
  });

  final DriverMissionResponseDto mission;
  final DriverWorkFeedItemDto? feedItem;
  final VoidCallback onOpenDetails;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final (label, background, foreground) = missionStatusPresentation(
      l10n,
      colors,
      mission.status,
    );
    final amount = feedItem?.amount;
    final amountValue = amount?.amount ?? mission.codExpectedAmount;
    final amountCurrency = amount?.currencyCode;
    final pickupLabel =
        feedItem?.pickup?.addressLine1 ?? feedItem?.pickup?.label;

    return NokiMapBottomPanel(
      child: Column(
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
                      mission.addressLine1,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      mission.customerFullName,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (onCall != null) ...[
                const SizedBox(width: AppSpacing.md),
                NokiMapControlButton(
                  icon: Icons.call_outlined,
                  tooltip: l10n.missionCallAction,
                  onPressed: onCall!,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (pickupLabel != null)
            _RouteRow(
              icon: Icons.trip_origin,
              label: l10n.missionSectionPickup,
              value: pickupLabel,
              color: colors.textMuted,
            ),
          if (pickupLabel != null) const SizedBox(height: AppSpacing.sm),
          _RouteRow(
            icon: Icons.place_outlined,
            label: l10n.missionSectionDropoff,
            value: mission.addressLine1,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.lg),
          NokiFinanceCallout(
            label: l10n.financeAmountToCollectLabel,
            amount: amountValue,
            currencyCode: amountCurrency,
            tone: NokiFinanceTone.collect,
            preferFcfa: true,
            caption: l10n.financeAmountToCollectHint,
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          NokiFinanceNotice(message: l10n.financeCodSafetyNotice),
          const SizedBox(height: AppSpacing.md),
          NokiOperationalBanner(
            icon: Icons.bolt_rounded,
            message:
                mission.status == DriverMissionResponseDtoStatus.outForDelivery
                ? l10n.missionMapNextActionOtp
                : l10n.missionCompleteRequiresOutForDelivery,
            tone: NokiBadgeTone.info,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onOpenDetails,
              child: Text(l10n.missionMapBackToDetails),
            ),
          ),
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
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
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

/// Which point the driver should be routed to, given the mission's real
/// status. `readyForDispatch`/`assigned` mean the package is not yet with
/// the driver - `assignedAt` is set but `outForDeliveryAt` is not, so the
/// driver still has a real driving leg to the pickup warehouse ahead of
/// them. `outForDelivery` is set once the driver scans the shipment QR at
/// pickup (`scanMissionQr`), which is the actual pickup event server-side -
/// from that point on the package is physically with the driver, so the
/// remaining leg is to the customer. `delivered`/`failed`/`cancelled` are
/// terminal: no further driving leg, so no navigation is offered.
MapPoint? _deliveryNavigationDestination(
  DriverMissionResponseDtoStatus status, {
  required MapPoint? pickup,
  required MapPoint? dropoff,
}) {
  switch (status) {
    case DriverMissionResponseDtoStatus.readyForDispatch:
    case DriverMissionResponseDtoStatus.assigned:
      return pickup;
    case DriverMissionResponseDtoStatus.outForDelivery:
      return dropoff;
    case DriverMissionResponseDtoStatus.delivered:
    case DriverMissionResponseDtoStatus.failed:
    case DriverMissionResponseDtoStatus.cancelled:
    case DriverMissionResponseDtoStatus.unknown:
      return null;
  }
}
