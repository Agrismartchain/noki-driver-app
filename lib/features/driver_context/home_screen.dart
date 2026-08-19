import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/connectivity/offline_banner.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/error_view.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/location/gps_publish_policy.dart';
import '../../core/location/gps_publisher.dart';
import '../../core/location/location_permission_state.dart';
import '../../core/location/location_repository.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../availability/availability_card.dart';
import '../availability/availability_repository.dart';
import '../delivery/delivery_mission_detail_screen.dart';
import '../delivery/delivery_repository.dart';
import '../mobility/mobility_repository.dart';
import '../mobility/mobility_ride_screen.dart';
import '../vehicles/vehicles_screen.dart';
import '../work_feed/work_feed_repository.dart';
import 'driver_context_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.onOpenWork});

  /// Switches the shell to the Work tab. Optional so this screen still
  /// compiles/renders standalone in tests that don't need it.
  final VoidCallback? onOpenWork;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncContext = ref.watch(driverContextProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: asyncContext.when(
              loading: () => const LoadingView(),
              error: (error, _) => ErrorView(
                failure: error is AppFailure ? error : const AppFailure(AppFailureType.unknown),
                onRetry: () => ref.invalidate(driverContextProvider),
              ),
              data: (context) => _HomeContent(context: context, onOpenWork: onOpenWork),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.context, this.onOpenWork});

  final DriverContextResponseDto context;
  final VoidCallback? onOpenWork;

  @override
  Widget build(BuildContext buildContext, WidgetRef ref) {
    final l10n = AppLocalizations.of(buildContext);
    final scope = activeScopeFrom(context);
    final profile = context.profiles.isNotEmpty ? context.profiles.first : null;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(driverContextProvider);
        if (scope != null) ref.invalidate(workFeedProvider(scope));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.homeGreeting(context.displayName), style: Theme.of(buildContext).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          if (profile != null && scope != null)
            _ProfileSummaryCard(
              profile: profile,
              onOpenVehicles: () => Navigator.of(buildContext).push(
                MaterialPageRoute(builder: (_) => VehiclesScreen(scope: scope)),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          if (scope != null) AvailabilityCard(scope: scope),
          const SizedBox(height: AppSpacing.lg),
          if (scope != null) _WorkFeedSummaryCard(scope: scope, onOpenWork: onOpenWork),
          if (scope != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _ActiveWorkAndTrackingCard(scope: scope),
          ],
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.profile, required this.onOpenVehicles});

  final DriverContextProfileDto profile;
  final VoidCallback onOpenVehicles;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final vehicle = profile.assignedVehicle;

    return Card(
      child: InkWell(
        onTap: onOpenVehicles,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(label: l10n.homeCountryLabel, value: profile.countryCode),
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                label: l10n.homeCapabilitiesLabel,
                value: _serviceCapabilitiesLabel(l10n, profile),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.homeVehicleLabel, style: Theme.of(context).textTheme.labelSmall),
                  Icon(Icons.chevron_right, size: 18, color: colors.textMuted),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              if (vehicle == null)
                Text(l10n.homeNoVehicle, style: TextStyle(color: colors.textMuted))
              else
                Text('${vehicle.make} ${vehicle.model} · ${vehicle.plate}'),
            ],
          ),
        ),
      ),
    );
  }
}

/// `DriverContextProfileDto.serviceTypes`'s OpenAPI enum only documents
/// TAXI/TAXI_MOTO - a real driver who also has a Delivery profile (as ours
/// now does, since the QA fixture provisions one) gets 'DELIVERY' in that
/// array too, which the generator correctly refuses to guess a label for
/// and maps to `unknown` (reported as a backend contract gap, not fixed
/// here - see DRIVER-APP-02 final report). Delivery capability is instead
/// read from the reliably-typed `deliveryStatus` field so it is never lost,
/// and unrecognized service types are omitted rather than shown as raw
/// "UNKNOWN" text (mandate §13).
String _serviceCapabilitiesLabel(AppLocalizations l10n, DriverContextProfileDto profile) {
  final labels = <String>[];
  if (profile.deliveryStatus != null) labels.add(l10n.workFeedTypeDelivery);
  for (final type in profile.serviceTypes) {
    switch (type) {
      case DriverContextProfileDtoServiceTypes.taxi:
        labels.add(l10n.serviceTypeTaxi);
      case DriverContextProfileDtoServiceTypes.taxiMoto:
        labels.add(l10n.serviceTypeTaxiMoto);
      case DriverContextProfileDtoServiceTypes.unknown:
        break;
    }
  }
  return labels.isEmpty ? l10n.homeNoServices : labels.join(' · ');
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

/// One tap back into whatever active Delivery/Ride the driver already has
/// (mandate §39), or, when idle, a compact tracking-status line (mandate
/// §38 - deliberately not a full map on Home; the mission/ride screens are
/// the right place for that). Also keeps [GpsPublisherController]'s idle
/// tracking context in sync with the driver's current availability while
/// Home is the active screen.
class _ActiveWorkAndTrackingCard extends ConsumerWidget {
  const _ActiveWorkAndTrackingCard({required this.scope});

  final DriverScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAvailability = ref.watch(availabilityProvider(scope));

    return asyncAvailability.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (availability) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(gpsPublisherControllerProvider).updateContext(
                DriverTrackingContext(
                  scope: scope,
                  deliveryAvailable: availability.deliveryStatus == DriverAvailabilityResponseDtoDeliveryStatus.active,
                  mobilityAvailable:
                      availability.mobilityAvailabilityStatus == DriverAvailabilityResponseDtoMobilityAvailabilityStatus.available,
                ),
              );
        });

        if (availability.activeMobilityRideCount > 0) {
          return _ContinueRideTile(scope: scope);
        }
        if (availability.activeDeliveryMissionCount > 0) {
          return _ContinueDeliveryTile(scope: scope);
        }
        return const _TrackingStatusTile();
      },
    );
  }
}

class _ContinueRideTile extends ConsumerWidget {
  const _ContinueRideTile({required this.scope});

  final DriverScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncRide = ref.watch(currentRideProvider(scope));
    return asyncRide.maybeWhen(
      data: (ride) => ride == null
          ? const SizedBox.shrink()
          : _ContinueTile(
              icon: Icons.local_taxi_outlined,
              label: l10n.homeContinueRide,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MobilityRideScreen(rideId: ride.id, scope: scope)),
              ),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ContinueDeliveryTile extends ConsumerWidget {
  const _ContinueDeliveryTile({required this.scope});

  final DriverScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (scope, 'OUT_FOR_DELIVERY');
    final asyncMissions = ref.watch(missionListByStatusProvider(key));
    return asyncMissions.maybeWhen(
      data: (list) => list.items.isEmpty
          ? const SizedBox.shrink()
          : _ContinueTile(
              icon: Icons.local_shipping_outlined,
              label: l10n.homeContinueDelivery,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DeliveryMissionDetailScreen(missionId: list.items.first.id, scope: scope)),
              ),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ContinueTile extends StatelessWidget {
  const _ContinueTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: colors.actionPrimary),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
              Icon(Icons.chevron_right, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackingStatusTile extends ConsumerWidget {
  const _TrackingStatusTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final asyncPermission = ref.watch(locationPermissionStateProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.gps_fixed, size: 18, color: colors.textMuted),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                asyncPermission.maybeWhen(
                  data: (state) => state == LocationPermissionState.granted ? l10n.homeTrackingIdle : l10n.homeTrackingPermissionNeeded,
                  orElse: () => l10n.homeTrackingIdle,
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkFeedSummaryCard extends ConsumerWidget {
  const _WorkFeedSummaryCard({required this.scope, this.onOpenWork});

  final DriverScope scope;
  final VoidCallback? onOpenWork;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncFeed = ref.watch(workFeedProvider(scope));

    return Card(
      child: InkWell(
        onTap: onOpenWork,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.homeWorkFeedSummaryTitle, style: Theme.of(context).textTheme.titleMedium),
                  if (onOpenWork != null) Icon(Icons.chevron_right, color: context.nokiColors.textMuted),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              asyncFeed.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(l10n.errorUnknown),
                data: (feed) => Text(l10n.homeWorkFeedSummaryCount(feed.total.toInt())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
