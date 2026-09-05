import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_localizer.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/noki_ui.dart';
import '../driver_context/driver_context_repository.dart';
import 'availability_repository.dart';

/// Reads and updates the driver's Mobility availability status. Values and
/// transitions are exactly the backend enum (OFFLINE/AVAILABLE/BUSY) - never
/// remapped to arbitrary UI labels - and a transition is only ever reflected
/// after the server confirms it (no optimistic update).
class AvailabilityCard extends ConsumerStatefulWidget {
  const AvailabilityCard({super.key, required this.scope});

  final DriverScope scope;

  @override
  ConsumerState<AvailabilityCard> createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends ConsumerState<AvailabilityCard> {
  bool _updating = false;
  AppFailure? _updateFailure;

  Future<void> _setStatus(
    UpdateDriverAvailabilityDtoAvailabilityStatus status,
  ) async {
    setState(() {
      _updating = true;
      _updateFailure = null;
    });
    try {
      await ref
          .read(availabilityRepositoryProvider)
          .update(widget.scope, status);
      ref.invalidate(availabilityProvider(widget.scope));
    } on AppFailure catch (failure) {
      setState(() => _updateFailure = failure);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final asyncAvailability = ref.watch(availabilityProvider(widget.scope));

    return NokiSurfaceCard(
      tone: NokiSurfaceTone.inverse,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.availabilityTitle,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: colors.textInverse),
                  ),
                ),
                const NokiBadge(
                  label: 'LIVE',
                  tone: NokiBadgeTone.primary,
                  icon: Icons.flash_on,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            asyncAvailability.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: LinearProgressIndicator(),
              ),
              error: (error, _) => Text(
                error is AppFailure
                    ? localizeFailure(context, error)
                    : l10n.errorUnknown,
                style: TextStyle(color: colors.danger),
              ),
              data: (availability) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NokiBadge(
                    label: _summaryLabel(
                      l10n,
                      availability.mobilityAvailabilityStatus,
                    ),
                    tone: _summaryTone(availability.mobilityAvailabilityStatus),
                    icon:
                        availability.mobilityAvailabilityStatus ==
                            DriverAvailabilityResponseDtoMobilityAvailabilityStatus
                                .available
                        ? Icons.radio_button_checked
                        : availability.mobilityAvailabilityStatus ==
                              DriverAvailabilityResponseDtoMobilityAvailabilityStatus
                                  .busy
                        ? Icons.timelapse
                        : Icons.pause_circle,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _StatusSelector(
                    current: availability.mobilityAvailabilityStatus,
                    updating: _updating,
                    onSelect: _setStatus,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      NokiMetricPill(
                        icon: Icons.local_shipping_outlined,
                        label: l10n.availabilityActiveMissions(
                          availability.activeDeliveryMissionCount.toInt(),
                        ),
                      ),
                      NokiMetricPill(
                        icon: Icons.local_taxi_outlined,
                        label: l10n.availabilityActiveRides(
                          availability.activeMobilityRideCount.toInt(),
                        ),
                      ),
                      NokiMetricPill(
                        icon: Icons.notifications_active_outlined,
                        label: l10n.availabilityPendingOffers(
                          availability.activeMobilityOfferCount.toInt(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_updateFailure != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.availabilityUpdateFailed,
                style: TextStyle(color: colors.danger),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({
    required this.current,
    required this.updating,
    required this.onSelect,
  });

  final DriverAvailabilityResponseDtoMobilityAvailabilityStatus? current;
  final bool updating;
  final void Function(UpdateDriverAvailabilityDtoAvailabilityStatus status)
  onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      (
        DriverAvailabilityResponseDtoMobilityAvailabilityStatus.offline,
        UpdateDriverAvailabilityDtoAvailabilityStatus.offline,
        l10n.availabilityStatusOffline,
      ),
      (
        DriverAvailabilityResponseDtoMobilityAvailabilityStatus.available,
        UpdateDriverAvailabilityDtoAvailabilityStatus.available,
        l10n.availabilityStatusAvailable,
      ),
      (
        DriverAvailabilityResponseDtoMobilityAvailabilityStatus.busy,
        UpdateDriverAvailabilityDtoAvailabilityStatus.busy,
        l10n.availabilityStatusBusy,
      ),
    ];

    if (updating) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(option.$3),
            selected: current == option.$1,
            onSelected: (_) => onSelect(option.$2),
          ),
      ],
    );
  }
}

String _summaryLabel(
  AppLocalizations l10n,
  DriverAvailabilityResponseDtoMobilityAvailabilityStatus? status,
) {
  return switch (status) {
    DriverAvailabilityResponseDtoMobilityAvailabilityStatus.available =>
      l10n.availabilityStatusAvailable,
    DriverAvailabilityResponseDtoMobilityAvailabilityStatus.busy =>
      l10n.availabilityStatusBusy,
    _ => l10n.availabilityStatusOffline,
  };
}

// Mandatory NOKI convention (mission mandate §8): AVAILABLE is always green,
// BUSY/active mission is always red, OFFLINE/UNAVAILABLE is neutral grey.
// `NokiBadgeTone.primary` (brand yellow) and `.warning` (amber) are reused
// elsewhere for brand emphasis and generic caution respectively - neither is
// the mandated color for a driver status pill, so the driver-status mapping
// must use `.success`/`.danger`/`.offline` specifically.
NokiBadgeTone _summaryTone(
  DriverAvailabilityResponseDtoMobilityAvailabilityStatus? status,
) {
  return switch (status) {
    DriverAvailabilityResponseDtoMobilityAvailabilityStatus.available =>
      NokiBadgeTone.success,
    DriverAvailabilityResponseDtoMobilityAvailabilityStatus.busy =>
      NokiBadgeTone.danger,
    _ => NokiBadgeTone.offline,
  };
}
