import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/connectivity/offline_banner.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/error_view.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/location/gps_publish_policy.dart';
import '../../core/location/gps_publisher.dart';
import '../../core/location/live_position_provider.dart';
import '../../core/location/location_permission_state.dart';
import '../../core/location/location_repository.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/noki_ui.dart';
import '../availability/availability_card.dart';
import '../availability/availability_repository.dart';
import '../delivery/delivery_mission_detail_screen.dart';
import '../delivery/delivery_repository.dart';
import '../map/map_chrome.dart';
import '../map/map_point.dart';
import '../map/map_view.dart';
import '../mobility/mobility_repository.dart';
import '../mobility/mobility_ride_screen.dart';
import '../vehicles/vehicles_screen.dart';
import '../work_feed/work_feed_repository.dart';
import 'driver_context_repository.dart';

/// Known country/city fallback coordinates used only to frame the embedded
/// Home map over the driver's real operating service zone before a live GPS
/// fix arrives. Never renders a fake driver marker.
MapPoint? _serviceAreaCenterForCountry(String? countryCode) {
  switch ((countryCode ?? '').trim().toUpperCase()) {
    case 'CG':
      return const MapPoint(-4.2634, 15.2429); // Brazzaville, Republic of Congo
    case 'CD':
      return const MapPoint(-4.4419, 15.2663); // Kinshasa, DR Congo
    case 'MA':
      return const MapPoint(33.5731, -7.5898); // Casablanca, Morocco
    case 'CM':
      return const MapPoint(4.0511, 9.7679); // Douala, Cameroon
    case 'CI':
      return const MapPoint(5.3600, -4.0083); // Abidjan, Côte d'Ivoire
    case 'SN':
      return const MapPoint(14.7167, -17.4677); // Dakar, Senegal
    case 'GA':
      return const MapPoint(0.4162, 9.4673); // Libreville, Gabon
    default:
      return null;
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.onOpenWork, this.tileProvider});

  /// Switches the shell to the Work tab. Optional so this screen still
  /// compiles/renders standalone in tests that don't need it.
  final VoidCallback? onOpenWork;

  /// Optional tile provider override for tests; defaults to [mapTileProvider].
  final TileProvider? tileProvider;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
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

  @override
  Widget build(BuildContext context) {
    final asyncContext = ref.watch(driverContextProvider);

    return Scaffold(
      body: NokiScreenBackground(
        safeTop: true,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xs),
            const OfflineBanner(),
            Expanded(
              child: asyncContext.when(
                loading: () => const LoadingView(),
                error: (error, _) => ErrorView(
                  failure: error is AppFailure
                      ? error
                      : const AppFailure(AppFailureType.unknown),
                  onRetry: () => ref.invalidate(driverContextProvider),
                ),
                data: (driverContext) => _HomeContent(
                  driverContext: driverContext,
                  onOpenWork: widget.onOpenWork,
                  tileProvider: widget.tileProvider,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({
    required this.driverContext,
    this.onOpenWork,
    this.tileProvider,
  });

  final DriverContextResponseDto driverContext;
  final VoidCallback? onOpenWork;
  final TileProvider? tileProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = activeScopeFrom(driverContext);
    final profile = driverContext.profiles.isNotEmpty
        ? driverContext.profiles.first
        : null;
    final metrics = context.nokiMetrics;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(driverContextProvider);
        ref.invalidate(locationPermissionStateProvider);
        ref.invalidate(livePositionProvider);
        if (scope != null) {
          ref.invalidate(availabilityProvider(scope));
          ref.invalidate(workFeedProvider(scope));
        }
      },
      child: SingleChildScrollView(
        key: const Key('home-scroll-view'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          metrics.pagePadding,
          AppSpacing.sm,
          metrics.pagePadding,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroHeader(
              driverName: driverContext.displayName,
              organizationName: profile?.organizationName,
              countryCode: profile?.countryCode,
            ),
            const SizedBox(height: AppSpacing.lg),
            _HomeMapCard(profile: profile, tileProvider: tileProvider),
            const SizedBox(height: AppSpacing.md),
            const _GpsActionBanner(),
            const SizedBox(height: AppSpacing.lg),
            if (scope != null) AvailabilityCard(scope: scope),
            const SizedBox(height: AppSpacing.lg),
            if (scope != null) _ActiveWorkAndTrackingCard(scope: scope),
            if (profile != null && scope != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _ProfileSummaryCard(
                profile: profile,
                onOpenVehicles: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VehiclesScreen(scope: scope),
                  ),
                ),
              ),
            ],
            if (scope != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _WorkFeedSummaryCard(scope: scope, onOpenWork: onOpenWork),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.driverName,
    this.organizationName,
    this.countryCode,
  });

  final String driverName;
  final String? organizationName;
  final String? countryCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final zoneSubtitle =
        organizationName != null && organizationName!.trim().isNotEmpty
        ? (countryCode != null && countryCode!.trim().isNotEmpty
              ? '$organizationName · $countryCode'
              : organizationName!)
        : l10n.appTitle;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          key: const Key('home-noki-logo'),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md - 1),
            child: Image.asset(
              'assets/brand/noki_logo.png',
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              semanticLabel: l10n.appTitle,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeGreeting(driverName),
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                zoneSubtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeMapCard extends ConsumerWidget {
  const _HomeMapCard({required this.profile, this.tileProvider});

  final DriverContextProfileDto? profile;
  final TileProvider? tileProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final asyncPermission = ref.watch(locationPermissionStateProvider);
    final permissionState = asyncPermission.valueOrNull;
    final isGranted = permissionState == LocationPermissionState.granted;

    // Only subscribe to the device live-position stream once location
    // permission is genuinely granted (avoids locking the stream in an error
    // state before the driver grants permission).
    final asyncPosition = isGranted ? ref.watch(livePositionProvider) : null;
    final position = asyncPosition?.valueOrNull;
    final driverPoint = position == null
        ? null
        : MapPoint(position.latitude, position.longitude);

    final fallbackCenter = _serviceAreaCenterForCountry(profile?.countryCode);
    final zoneLabel = profile == null
        ? null
        : '${profile!.organizationName} (${profile!.countryCode})';
    final effectiveTileProvider = tileProvider ?? ref.watch(mapTileProvider);

    final (gpsLabel, gpsIcon, gpsBg, gpsFg) = _gpsChipStyle(
      l10n: l10n,
      colors: colors,
      permissionState: permissionState,
      hasLiveFix: driverPoint != null,
      positionHasError: asyncPosition?.hasError == true,
    );

    return NokiSurfaceCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.nokiMetrics.radiusCard - 1),
        child: SizedBox(
          key: const Key('home-embedded-map'),
          height: 210,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: NokiMapView(
                  driverPosition: driverPoint,
                  fallbackCenter: fallbackCenter,
                  fallbackZoom: 12,
                  interactive: false,
                  showRecenterButton: driverPoint != null,
                  tileProvider: effectiveTileProvider,
                ),
              ),
              PositionedDirectional(
                top: AppSpacing.sm,
                start: AppSpacing.sm,
                end: AppSpacing.sm,
                child: IgnorePointer(
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (zoneLabel != null)
                        NokiMapStatusChip(
                          label: l10n.homeMapServiceZone(zoneLabel),
                          icon: Icons.public_outlined,
                          backgroundColor: colors.surfaceElevated,
                          foregroundColor: colors.textPrimary,
                        ),
                      NokiMapStatusChip(
                        label: gpsLabel,
                        icon: gpsIcon,
                        backgroundColor: gpsBg,
                        foregroundColor: gpsFg,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, IconData, Color, Color) _gpsChipStyle({
    required AppLocalizations l10n,
    required dynamic colors,
    required LocationPermissionState? permissionState,
    required bool hasLiveFix,
    required bool positionHasError,
  }) {
    if (permissionState == LocationPermissionState.serviceDisabled) {
      return (
        l10n.mapGpsDisabled,
        Icons.location_off_outlined,
        colors.warningSurface as Color,
        colors.warning as Color,
      );
    }
    if (permissionState == LocationPermissionState.deniedOnce ||
        permissionState == LocationPermissionState.deniedForever) {
      return (
        l10n.mapGpsUnavailable,
        Icons.gps_off_rounded,
        colors.warningSurface as Color,
        colors.warning as Color,
      );
    }
    if (hasLiveFix) {
      return (
        l10n.homeMapPositionLive,
        Icons.my_location_rounded,
        colors.successSurface as Color,
        colors.success as Color,
      );
    }
    if (positionHasError) {
      return (
        l10n.mapGpsUnavailable,
        Icons.gps_off_rounded,
        colors.dangerSurface as Color,
        colors.danger as Color,
      );
    }
    return (
      l10n.homeMapWaitingGps,
      Icons.gps_fixed_outlined,
      colors.surfaceElevated as Color,
      colors.textPrimary as Color,
    );
  }
}

/// Actionable GPS banner directly driven by the real device permission and
/// location-service state. Hidden when location is granted and working;
/// otherwise exposes the exact next step (request permission, open location
/// settings, or open app settings) and refreshes automatically on resume.
class _GpsActionBanner extends ConsumerStatefulWidget {
  const _GpsActionBanner();

  @override
  ConsumerState<_GpsActionBanner> createState() => _GpsActionBannerState();
}

class _GpsActionBannerState extends ConsumerState<_GpsActionBanner> {
  bool _busy = false;

  Future<void> _requestPermission() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(locationRepositoryProvider).requestPermission();
      ref.invalidate(locationPermissionStateProvider);
      ref.invalidate(livePositionProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openLocationSettings() async {
    await ref.read(locationRepositoryProvider).openLocationSettings();
  }

  Future<void> _openAppSettings() async {
    await ref.read(locationRepositoryProvider).openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final asyncPermission = ref.watch(locationPermissionStateProvider);

    return asyncPermission.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => NokiOperationalBanner(
        icon: Icons.location_disabled_outlined,
        message: l10n.locationErrorGeneric,
        tone: NokiBadgeTone.warning,
        action: TextButton(
          onPressed: () {
            ref.invalidate(locationPermissionStateProvider);
            ref.invalidate(livePositionProvider);
          },
          style: TextButton.styleFrom(foregroundColor: colors.warning),
          child: Text(l10n.actionRetry),
        ),
      ),
      data: (state) {
        switch (state) {
          case LocationPermissionState.granted:
            return const SizedBox.shrink();
          case LocationPermissionState.deniedOnce:
            return NokiOperationalBanner(
              key: const Key('home-gps-banner'),
              icon: Icons.my_location_outlined,
              message: l10n.homeTrackingPermissionNeeded,
              tone: NokiBadgeTone.warning,
              action: FilledButton(
                onPressed: _busy ? null : _requestPermission,
                child: Text(l10n.locationGrantAction),
              ),
            );
          case LocationPermissionState.serviceDisabled:
            return NokiOperationalBanner(
              key: const Key('home-gps-banner'),
              icon: Icons.location_off_outlined,
              message: l10n.locationServiceDisabled,
              tone: NokiBadgeTone.warning,
              action: FilledButton(
                onPressed: _openLocationSettings,
                child: Text(l10n.locationOpenLocationSettings),
              ),
            );
          case LocationPermissionState.deniedForever:
            return NokiOperationalBanner(
              key: const Key('home-gps-banner'),
              icon: Icons.location_off_outlined,
              message: l10n.locationDeniedForever,
              tone: NokiBadgeTone.danger,
              action: FilledButton(
                onPressed: _openAppSettings,
                child: Text(l10n.locationOpenSettings),
              ),
            );
        }
      },
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.profile,
    required this.onOpenVehicles,
  });

  final DriverContextProfileDto profile;
  final VoidCallback onOpenVehicles;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final vehicle = profile.assignedVehicle;

    return NokiSurfaceCard(
      onTap: onOpenVehicles,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NokiSectionHeader(
            title: l10n.homeVehicleLabel,
            subtitle: _serviceCapabilitiesLabel(l10n, profile),
            trailing: Icon(
              Icons.chevron_right,
              size: 18,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoRow(label: l10n.homeCountryLabel, value: profile.countryCode),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            label: l10n.homeCapabilitiesLabel,
            value: _serviceCapabilitiesLabel(l10n, profile),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (vehicle == null)
            Text(l10n.homeNoVehicle, style: TextStyle(color: colors.textMuted))
          else
            Text(
              '${vehicle.make} ${vehicle.model} · ${vehicle.plate}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
        ],
      ),
    );
  }
}

/// `DriverContextProfileDto.serviceTypes`'s OpenAPI enum only documents
/// TAXI/TAXI_MOTO - a real driver who also has a Delivery profile gets
/// 'DELIVERY' in that array too, which maps to `unknown`. Delivery capability
/// is read from the reliably-typed `deliveryStatus` field so it is never lost,
/// and unrecognized service types are omitted rather than shown as raw
/// "UNKNOWN" text.
String _serviceCapabilitiesLabel(
  AppLocalizations l10n,
  DriverContextProfileDto profile,
) {
  final labels = <String>[];
  if (profile.deliveryStatus != null) labels.add(l10n.workFeedTypeDelivery);
  for (final type in profile.serviceTypes) {
    switch (type) {
      case DriverContextProfileDtoServiceTypes.taxi:
        labels.add(l10n.serviceTypeTaxi);
      case DriverContextProfileDtoServiceTypes.taxiMoto:
        labels.add(l10n.serviceTypeTaxiMoto);
      case DriverContextProfileDtoServiceTypes.courier:
        labels.add(l10n.serviceTypeCourier);
      case DriverContextProfileDtoServiceTypes.cargo:
        labels.add(l10n.serviceTypeCargo);
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

/// One tap back into whatever active Delivery/Ride the driver already has, or,
/// when idle, a compact tracking-status line. Also keeps
/// [GpsPublisherController]'s idle tracking context in sync with the driver's
/// current availability while Home is the active screen.
class _ActiveWorkAndTrackingCard extends ConsumerWidget {
  const _ActiveWorkAndTrackingCard({required this.scope});

  final DriverScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAvailability = ref.watch(availabilityProvider(scope));
    final currentRide = ref.watch(currentRideProvider(scope)).valueOrNull;

    return asyncAvailability.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (availability) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(gpsPublisherControllerProvider)
              .updateContext(
                DriverTrackingContext(
                  scope: scope,
                  deliveryAvailable:
                      availability.deliveryStatus ==
                      DriverAvailabilityResponseDtoDeliveryStatus.active,
                  mobilityAvailable:
                      availability.mobilityAvailabilityStatus ==
                      DriverAvailabilityResponseDtoMobilityAvailabilityStatus
                          .available,
                ),
              );
        });

        if (currentRide != null || availability.activeMobilityRideCount > 0) {
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
    final ride = asyncRide.valueOrNull;

    return _ContinueTile(
      icon: Icons.local_taxi_outlined,
      label: l10n.homeContinueRide,
      onTap: ride == null
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    MobilityRideScreen(rideId: ride.id, scope: scope),
              ),
            ),
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
                MaterialPageRoute(
                  builder: (_) => DeliveryMissionDetailScreen(
                    missionId: list.items.first.id,
                    scope: scope,
                  ),
                ),
              ),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ContinueTile extends StatelessWidget {
  const _ContinueTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    return NokiSurfaceCard(
      tone: NokiSurfaceTone.selected,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: colors.textPrimary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          Icon(Icons.chevron_right, color: colors.textMuted),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: NokiMetricPill(icon: icon, label: label),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          value,
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
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
    final state = asyncPermission.valueOrNull;

    // When permission/GPS is missing, `_GpsActionBanner` above already displays
    // the actionable prompt - avoid duplicating a non-interactive line.
    if (state != null && state != LocationPermissionState.granted) {
      return const SizedBox.shrink();
    }

    return NokiSurfaceCard(
      tone: NokiSurfaceTone.subtle,
      child: Row(
        children: [
          Icon(Icons.gps_fixed, size: 18, color: colors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.homeTrackingIdle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
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

    return NokiSurfaceCard(
      key: const Key('home-work-feed-summary-card'),
      onTap: onOpenWork,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NokiSectionHeader(
            title: l10n.homeWorkFeedSummaryTitle,
            subtitle: l10n.navWork,
            trailing: onOpenWork != null
                ? Icon(Icons.chevron_right, color: context.nokiColors.textMuted)
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          asyncFeed.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text(l10n.errorUnknown),
            data: (feed) => _StatRow(
              icon: Icons.inbox_outlined,
              label: l10n.homeWorkFeedSummaryCount(feed.total.toInt()),
              value: feed.items.isEmpty ? '--' : feed.items.first.status,
            ),
          ),
        ],
      ),
    );
  }
}
