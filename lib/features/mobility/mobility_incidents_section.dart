import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_localizer.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../driver_context/driver_context_repository.dart';
import 'mobility_repository.dart';
import 'mobility_status_presentation.dart';

/// Mobility's incident section, mirroring the Delivery-side pattern
/// (`_incidentsContent()` in delivery_mission_detail_screen.dart) that has
/// already been live-validated - dropdown + optional comment + submit, plus
/// the existing incident list. `MobilityIncidentDto` carries no `rideId`,
/// only a human-readable `rideReference`, so the list is scoped to this ride
/// by matching `incident.rideReference == rideReference` (mandate §22:
/// "no fake success" - an incident genuinely filed against a different ride
/// or a non-ride-specific report never appears here).
///
/// `mobilityRepositoryProvider`/`mobilityIncidentsProvider` and every label
/// helper this widget uses (`mobilityIncidentTypeLabel`,
/// `mobilityIncidentStatusPresentation`) already existed before this phase,
/// wired to the API client but never reached by any screen - this widget is
/// the first thing that actually calls them.
class MobilityIncidentsSection extends ConsumerStatefulWidget {
  const MobilityIncidentsSection({super.key, required this.scope, required this.rideId, required this.rideReference});

  final DriverScope scope;
  final String rideId;
  final String rideReference;

  @override
  ConsumerState<MobilityIncidentsSection> createState() => _MobilityIncidentsSectionState();
}

class _MobilityIncidentsSectionState extends ConsumerState<MobilityIncidentsSection> {
  bool _submitting = false;
  AppFailure? _failure;
  CreateOwnMobilityIncidentRequestDtoType _type = CreateOwnMobilityIncidentRequestDtoType.ride;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _failure = null;
    });
    try {
      final comment = _commentController.text.trim();
      await ref.read(mobilityRepositoryProvider).createIncident(
            widget.scope,
            rideId: widget.rideId,
            type: _type,
            comment: comment.isEmpty ? null : comment,
          );
      _commentController.clear();
      ref.invalidate(mobilityIncidentsProvider(widget.scope));
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final asyncIncidents = ref.watch(mobilityIncidentsProvider(widget.scope));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.missionSectionIncidents, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            asyncIncidents.when(
              loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.sm), child: LinearProgressIndicator()),
              error: (error, _) => Text(
                error is AppFailure ? localizeFailure(context, error) : l10n.errorUnknown,
                style: TextStyle(color: colors.danger),
              ),
              data: (list) {
                final rideIncidents = list.items.where((incident) => incident.rideReference == widget.rideReference).toList();
                if (rideIncidents.isEmpty) {
                  return Text(l10n.incidentsEmpty, style: TextStyle(color: colors.textMuted));
                }
                return Column(
                  children: [
                    for (final incident in rideIncidents)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _IncidentTile(incident: incident),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<CreateOwnMobilityIncidentRequestDtoType>(
              initialValue: _type,
              // Without isExpanded, a closed DropdownButtonFormField sizes
              // itself to fit its *widest* item (so the trigger doesn't
              // resize on selection) - "Customer complaint" doesn't fit at
              // narrow widths otherwise. Caught by a real widget test
              // (mandate DRIVER-APP-04 §37/§52).
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.incidentTypeLabel),
              items: [
                DropdownMenuItem(value: CreateOwnMobilityIncidentRequestDtoType.ride, child: Text(l10n.mobilityIncidentTypeRide)),
                DropdownMenuItem(value: CreateOwnMobilityIncidentRequestDtoType.driver, child: Text(l10n.mobilityIncidentTypeDriver)),
                DropdownMenuItem(value: CreateOwnMobilityIncidentRequestDtoType.vehicle, child: Text(l10n.incidentTypeVehicleIssue)),
                DropdownMenuItem(
                  value: CreateOwnMobilityIncidentRequestDtoType.customerComplaint,
                  child: Text(l10n.mobilityIncidentTypeCustomerComplaint),
                ),
                DropdownMenuItem(value: CreateOwnMobilityIncidentRequestDtoType.safety, child: Text(l10n.incidentTypeSafety)),
                DropdownMenuItem(value: CreateOwnMobilityIncidentRequestDtoType.other, child: Text(l10n.incidentTypeOther)),
              ],
              onChanged: _submitting ? null : (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _commentController,
              maxLength: 500,
              maxLines: 2,
              enabled: !_submitting,
              decoration: InputDecoration(labelText: l10n.incidentCommentLabel),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.incidentSubmitCta),
            ),
            if (_failure != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(localizeFailure(context, _failure!), style: TextStyle(color: colors.danger)),
            ],
          ],
        ),
      ),
    );
  }
}

class _IncidentTile extends StatelessWidget {
  const _IncidentTile({required this.incident});

  final MobilityIncidentDto incident;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final (label, background, foreground) = mobilityIncidentStatusPresentation(l10n, colors, incident.status);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(color: colors.surfaceSubtle, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mobilityIncidentTypeLabel(l10n, incident.type), style: Theme.of(context).textTheme.bodyMedium),
                if (incident.comment != null) Text(incident.comment!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.full)),
            child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground)),
          ),
        ],
      ),
    );
  }
}
