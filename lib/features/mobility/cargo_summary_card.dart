import 'package:flutter/material.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'mobility_status_presentation.dart';

/// Full Cargo summary card - real backend data only (vehicleClass,
/// cargoWeightKg, cargoQuantity, fragile, cargoDescription, optional
/// dimensions), never a fabricated fallback. Shared by the offer detail and
/// active ride detail screens so a driver sees the identical Cargo section
/// at every stage (mandate: CARGO_LOAD_SUMMARY, NO_FAKE_CARGO_DATA).
class CargoSummaryCard extends StatelessWidget {
  const CargoSummaryCard({super.key, required this.cargo});

  final DriverCargoSummaryDto cargo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final dimensions = _dimensionsText(cargo);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: colors.actionPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.mobilityCargoSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (cargo.fragile) ...[
                  const Spacer(),
                  _FragileBadge(label: l10n.mobilityCargoFragileLabel),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _CargoField(
              label: l10n.mobilityCargoVehicleRequiredLabel,
              value: cargoVehicleClassLabel(l10n, cargo.vehicleClass),
            ),
            const SizedBox(height: AppSpacing.sm),
            _CargoField(
              label: l10n.mobilityCargoWeightLabel,
              value: '${cargo.cargoWeightKg} kg',
            ),
            const SizedBox(height: AppSpacing.sm),
            _CargoField(
              label: l10n.mobilityCargoQuantityLabel,
              value: '${cargo.cargoQuantity}',
            ),
            if (dimensions != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _CargoField(
                label: l10n.mobilityCargoDimensionsLabel,
                value: dimensions,
              ),
            ],
            if (cargo.cargoDescription.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _CargoField(
                label: l10n.mobilityCargoDescriptionLabel,
                value: cargo.cargoDescription,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact vehicle-class + weight line for the Work Feed card - full details
/// (dimensions, fragility, description) live in the detail screen, reached
/// on tap.
class CargoSummaryLine extends StatelessWidget {
  const CargoSummaryLine({super.key, required this.cargo});

  final DriverCargoSummaryDto cargo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    return Row(
      children: [
        Icon(Icons.local_shipping_outlined, size: 14, color: colors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            '${cargoVehicleClassLabel(l10n, cargo.vehicleClass)} · ${cargo.cargoWeightKg} kg',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String? _dimensionsText(DriverCargoSummaryDto cargo) {
  final length = cargo.cargoLengthCm;
  final width = cargo.cargoWidthCm;
  final height = cargo.cargoHeightCm;
  if (length == null && width == null && height == null) return null;
  final parts = [length, width, height].map((v) => v?.toString() ?? '—');
  return '${parts.join(' × ')} cm';
}

class _CargoField extends StatelessWidget {
  const _CargoField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: colors.textMuted),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _FragileBadge extends StatelessWidget {
  const _FragileBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.warningSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: colors.warning),
      ),
    );
  }
}
