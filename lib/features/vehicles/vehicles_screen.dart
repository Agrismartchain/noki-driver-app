import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/error_view.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/noki_ui.dart';
import '../driver_context/driver_context_repository.dart';
import 'vehicles_repository.dart';

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key, required this.scope});

  final DriverScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncVehicles = ref.watch(vehiclesProvider(scope));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vehiclesTitle)),
      body: NokiScreenBackground(
        child: asyncVehicles.when(
          loading: () => const LoadingView(),
          error: (error, _) => ErrorView(
            failure: error is AppFailure
                ? error
                : const AppFailure(AppFailureType.unknown),
            onRetry: () => ref.invalidate(vehiclesProvider(scope)),
          ),
          data: (list) {
            if (list.items.isEmpty) {
              return EmptyView(
                icon: Icons.directions_car_outlined,
                title: l10n.vehiclesEmpty,
                body: l10n.vehiclesEmptyBody,
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(vehiclesProvider(scope)),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: list.items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    _VehicleTile(vehicle: list.items[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({required this.vehicle});

  final DriverVehicleDto vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;

    return NokiSurfaceCard(
      tone: vehicle.status == DriverVehicleDtoStatus.active
          ? NokiSurfaceTone.defaultTone
          : NokiSurfaceTone.subtle,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              vehicle.type == DriverVehicleDtoType.motorcycle
                  ? Icons.moped_outlined
                  : Icons.directions_car_outlined,
              color: colors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.make} ${vehicle.model}',
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      NokiBadge(
                        label: vehicle.type == DriverVehicleDtoType.motorcycle
                            ? l10n.vehicleTypeMotorcycle
                            : l10n.vehicleTypeCar,
                        tone: NokiBadgeTone.neutral,
                      ),
                      for (final service in vehicle.allowedServiceTypes)
                        NokiBadge(
                          label: switch (service) {
                            DriverVehicleDtoAllowedServiceTypes.taxi =>
                              l10n.serviceTypeTaxi,
                            DriverVehicleDtoAllowedServiceTypes.taxiMoto =>
                              l10n.serviceTypeTaxiMoto,
                            DriverVehicleDtoAllowedServiceTypes.unknown =>
                              l10n.errorUnknown,
                          },
                          tone: NokiBadgeTone.info,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Text(
                        '${l10n.vehiclePlateLabel}: ${vehicle.plate}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      _VehicleStatusBadge(status: vehicle.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleStatusBadge extends StatelessWidget {
  const _VehicleStatusBadge({required this.status});

  final DriverVehicleDtoStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;

    final (label, background, foreground) = switch (status) {
      DriverVehicleDtoStatus.active => (
        l10n.vehicleStatusActive,
        colors.successSurface,
        colors.success,
      ),
      DriverVehicleDtoStatus.pendingValidation => (
        l10n.vehicleStatusPendingValidation,
        colors.warningSurface,
        colors.warning,
      ),
      DriverVehicleDtoStatus.suspended => (
        l10n.vehicleStatusSuspended,
        colors.dangerSurface,
        colors.danger,
      ),
      DriverVehicleDtoStatus.retired => (
        l10n.vehicleStatusRetired,
        colors.surfaceSubtle,
        colors.textMuted,
      ),
      DriverVehicleDtoStatus.unknown => (
        l10n.errorUnknown,
        colors.surfaceSubtle,
        colors.textMuted,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foreground),
      ),
    );
  }
}
