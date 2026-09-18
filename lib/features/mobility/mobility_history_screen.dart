import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/error_view.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/noki_finance.dart';
import '../../core/ui/noki_ui.dart';
import '../driver_context/driver_context_repository.dart';
import 'mobility_repository.dart';
import 'mobility_ride_screen.dart';

class MobilityHistoryScreen extends ConsumerWidget {
  const MobilityHistoryScreen({super.key, required this.scope});

  final DriverScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRides = ref.watch(mobilityRideHistoryProvider(scope));

    return Scaffold(
      appBar: AppBar(title: const Text('Historique Mobility')),
      body: NokiScreenBackground(
        child: asyncRides.when(
          loading: () => const LoadingView(),
          error: (error, _) => ErrorView(
            failure: error is AppFailure
                ? error
                : const AppFailure(AppFailureType.unknown),
            onRetry: () => ref.invalidate(mobilityRideHistoryProvider(scope)),
          ),
          data: (rides) {
            if (rides.isEmpty) {
              return const EmptyView(
                icon: Icons.history,
                title: 'Aucune course Mobility terminee',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: rides.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final ride = rides[index];
                return _MobilityHistoryTile(ride: ride, scope: scope);
              },
            );
          },
        ),
      ),
    );
  }
}

class _MobilityHistoryTile extends StatelessWidget {
  const _MobilityHistoryTile({required this.ride, required this.scope});

  final MobilityRideDetailDto ride;
  final DriverScope scope;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final l10n = AppLocalizations.of(context);
    return NokiSurfaceCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MobilityRideScreen(rideId: ride.id, scope: scope),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    NokiBadge(
                      label: _serviceLabel(l10n, ride.serviceType),
                      tone: NokiBadgeTone.primary,
                      icon: _serviceIcon(ride.serviceType),
                    ),
                    NokiBadge(
                      label: _statusLabel(l10n, ride.status),
                      tone: ride.status == MobilityRideDetailDtoStatus.completed
                          ? NokiBadgeTone.success
                          : NokiBadgeTone.danger,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textMuted),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            ride.pickupAddressSnapshot,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            ride.dropoffAddressSnapshot,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            ride.completedAt ?? ride.updatedAt,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          NokiFinanceCallout(
            label: l10n.mobilityFareLabel,
            amount: ride.fareAmount.toString(),
            currencyCode: ride.currencyCode,
            tone: NokiFinanceTone.earnings,
          ),
        ],
      ),
    );
  }
}

String _serviceLabel(
  AppLocalizations l10n,
  MobilityRideDetailDtoServiceType serviceType,
) {
  switch (serviceType) {
    case MobilityRideDetailDtoServiceType.taxi:
      return l10n.serviceTypeTaxi;
    case MobilityRideDetailDtoServiceType.taxiMoto:
      return l10n.serviceTypeTaxiMoto;
    case MobilityRideDetailDtoServiceType.cargo:
      return l10n.serviceTypeCargo;
    case MobilityRideDetailDtoServiceType.courier:
      return l10n.serviceTypeCourier;
    case MobilityRideDetailDtoServiceType.unknown:
      return serviceType.toJson();
  }
}

IconData _serviceIcon(MobilityRideDetailDtoServiceType serviceType) {
  switch (serviceType) {
    case MobilityRideDetailDtoServiceType.taxiMoto:
      return Icons.two_wheeler_outlined;
    case MobilityRideDetailDtoServiceType.cargo:
      return Icons.local_shipping_outlined;
    default:
      return Icons.local_taxi_outlined;
  }
}

String _statusLabel(AppLocalizations l10n, MobilityRideDetailDtoStatus status) {
  switch (status) {
    case MobilityRideDetailDtoStatus.completed:
      return l10n.rideStatusCompleted;
    case MobilityRideDetailDtoStatus.cancelled:
      return l10n.rideStatusCancelled;
    default:
      return status.toJson();
  }
}
