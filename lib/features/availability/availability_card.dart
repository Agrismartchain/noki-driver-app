import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_localizer.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
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

  Future<void> _setStatus(UpdateDriverAvailabilityDtoAvailabilityStatus status) async {
    setState(() {
      _updating = true;
      _updateFailure = null;
    });
    try {
      await ref.read(availabilityRepositoryProvider).update(widget.scope, status);
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.availabilityTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            asyncAvailability.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: LinearProgressIndicator(),
              ),
              error: (error, _) => Text(
                error is AppFailure ? localizeFailure(context, error) : l10n.errorUnknown,
                style: TextStyle(color: colors.danger),
              ),
              data: (availability) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusSelector(
                    current: availability.mobilityAvailabilityStatus,
                    updating: _updating,
                    onSelect: _setStatus,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.availabilityActiveMissions(availability.activeDeliveryMissionCount.toInt()),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    l10n.availabilityActiveRides(availability.activeMobilityRideCount.toInt()),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    l10n.availabilityPendingOffers(availability.activeMobilityOfferCount.toInt()),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (_updateFailure != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.availabilityUpdateFailed, style: TextStyle(color: colors.danger)),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({required this.current, required this.updating, required this.onSelect});

  final DriverAvailabilityResponseDtoMobilityAvailabilityStatus? current;
  final bool updating;
  final void Function(UpdateDriverAvailabilityDtoAvailabilityStatus status) onSelect;

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
        child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
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
