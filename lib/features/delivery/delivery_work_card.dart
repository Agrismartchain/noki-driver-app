import 'package:flutter/material.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'delivery_status_presentation.dart';

/// Work Feed card for a DELIVERY work item. Deliberately distinct from
/// [MobilityWorkCard] (parcel icon, pickup->dropoff line, COD badge) so a
/// driver cannot mistake a parcel for a ride at a glance - see mandate
/// DRIVER-APP-02 §14/§15.
class DeliveryWorkCard extends StatelessWidget {
  const DeliveryWorkCard({super.key, required this.item, required this.onTap});

  final DriverWorkFeedItemDto item;
  final VoidCallback onTap;

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
              Icon(Icons.local_shipping_outlined, color: colors.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A Wrap, not a Row: a long localized status pill (e.g.
                    // French "En cours de livraison") next to the type label
                    // can legitimately not fit on one line at 320dp - it
                    // drops to its own line instead of overflowing. Same
                    // pattern as vehicles_screen.dart's _VehicleStatusBadge.
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Text(
                          l10n.workFeedTypeDelivery,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.textMuted),
                        ),
                        _StatusPill(status: DriverMissionResponseDtoStatus.fromJson(item.status)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (item.pickup?.addressLine1 != null || item.pickup?.label != null)
                      _RouteLine(
                        icon: Icons.trip_origin,
                        // addressLine1 is the real address when present; the
                        // backend's `label` is a generic placeholder
                        // ('Pickup'/'Dropoff'/'Customer') except for the
                        // delivery pickup case, where it is the real
                        // warehouse name and addressLine1 is null.
                        label: item.pickup!.addressLine1 ?? item.pickup!.label!,
                        color: colors.textMuted,
                      ),
                    if (item.dropoff?.addressLine1 != null || item.dropoff?.label != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _RouteLine(
                        icon: Icons.place_outlined,
                        label: item.dropoff!.addressLine1 ?? item.dropoff!.label!,
                        color: colors.textPrimary,
                      ),
                    ],
                    if (item.amount != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(color: colors.surfaceSelected, borderRadius: BorderRadius.circular(AppRadius.sm)),
                        child: Text(
                          l10n.deliveryCodBadge('${item.amount!.amount} ${item.amount!.currencyCode}'),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
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
  const _RouteLine({required this.icon, required this.label, required this.color});

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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final DriverMissionResponseDtoStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final (label, background, foreground) = missionStatusPresentation(l10n, colors, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground)),
    );
  }
}
