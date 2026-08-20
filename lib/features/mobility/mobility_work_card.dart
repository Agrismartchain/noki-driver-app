import 'package:flutter/material.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/noki_finance.dart';
import 'mobility_status_presentation.dart';

/// Work Feed card for a RIDE work item (either an open offer or an active
/// ride - discriminated by `sourceDomain`, see [isOffer]). Deliberately
/// distinct from [DeliveryWorkCard]: a car/moped icon by service type, no
/// COD badge, an estimated-fare pill instead - a driver must never confuse
/// a ride with a parcel (mandate §15).
class MobilityWorkCard extends StatelessWidget {
  const MobilityWorkCard({super.key, required this.item, required this.onTap});

  final DriverWorkFeedItemDto item;
  final VoidCallback onTap;

  bool get isOffer => item.sourceDomain == 'MOBILITY_OFFER';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.serviceType == DriverWorkFeedItemDtoServiceType.taxiMoto
                    ? Icons.moped_outlined
                    : Icons.local_taxi_outlined,
                color: colors.actionPrimary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${workFeedServiceTypeLabel(l10n, item.serviceType)} · ${isOffer ? l10n.mobilityOfferLabel : l10n.mobilityRideLabel}',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: colors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // addressLine1 is the real address when present; the
                    // backend's `label` on Mobility work items is always a
                    // generic 'Pickup'/'Dropoff' placeholder, never the
                    // actual address.
                    if (item.pickup?.addressLine1 != null ||
                        item.pickup?.label != null)
                      _RouteLine(
                        icon: Icons.trip_origin,
                        label: item.pickup!.addressLine1 ?? item.pickup!.label!,
                        color: colors.textMuted,
                      ),
                    if (item.dropoff?.addressLine1 != null ||
                        item.dropoff?.label != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _RouteLine(
                        icon: Icons.place_outlined,
                        label:
                            item.dropoff!.addressLine1 ?? item.dropoff!.label!,
                        color: colors.textPrimary,
                      ),
                    ],
                    if (item.amount != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      NokiFinanceCallout(
                        label: l10n.financeEstimatedFareLabel,
                        amount: item.amount!.amount,
                        currencyCode: item.amount!.currencyCode,
                        caption: isOffer
                            ? l10n.mobilityOfferLabel
                            : l10n.mobilityRideLabel,
                        icon: Icons.payments_outlined,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
