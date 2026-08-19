import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncMission = ref.watch(missionDetailProvider(widget.missionId));

    final pickup = widget.feedItem?.pickup;
    final dropoff = widget.feedItem?.dropoff;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.missionMapTitle)),
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
          return Stack(
            children: [
              NokiMapView(
                tileProvider: widget.tileProvider,
                driverPosition: asyncPosition.whenOrNull(
                  data: (p) => MapPoint(p.latitude, p.longitude),
                ),
                pickup: pickup?.latitude != null && pickup?.longitude != null
                    ? MapPoint(
                        pickup!.latitude!.toDouble(),
                        pickup.longitude!.toDouble(),
                      )
                    : null,
                dropoff: dropoff?.latitude != null && dropoff?.longitude != null
                    ? MapPoint(
                        dropoff!.latitude!.toDouble(),
                        dropoff.longitude!.toDouble(),
                      )
                    : null,
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: asyncMission.maybeWhen(
                  data: (mission) => _BottomSheet(mission: mission),
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
  const _BottomSheet({required this.mission});

  final DriverMissionResponseDto mission;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final (label, background, foreground) = missionStatusPresentation(
      l10n,
      colors,
      mission.status,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
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
                mission.status == DriverMissionResponseDtoStatus.outForDelivery
                    ? l10n.missionMapNextActionOtp
                    : l10n.missionCompleteRequiresOutForDelivery,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.nokiColors.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.missionMapBackToDetails),
            ),
          ],
        ),
      ),
    );
  }
}
