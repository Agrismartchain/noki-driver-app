import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/error_view.dart';
import '../../core/errors/failure_localizer.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/idempotency_key.dart';
import '../availability/availability_repository.dart';
import '../driver_context/driver_context_repository.dart';
import '../work_feed/work_feed_repository.dart';
import 'delivery_mission_map_screen.dart';
import 'delivery_repository.dart';
import 'delivery_status_presentation.dart';

/// The first serious Delivery mission detail experience (mandate §17/§18).
/// Every action here is exactly one of the driver-legal endpoints confirmed
/// by the contract audit: request/verify handoff OTP, complete (the only
/// status-mutating transition a driver can perform), and report an
/// incident. There is no accept/pickup/arrive action because no such
/// endpoint exists server-side.
///
/// Pickup has no coordinates or address on `GET /v1/delivery/missions/:id`
/// at all - only the Work Feed item carries it (from the fulfillment
/// warehouse). [feedItem] is passed in from whichever list navigated here so
/// the Pickup/Financial sections can show it; if this screen is ever reached
/// without one, those sections degrade honestly instead of guessing.
class DeliveryMissionDetailScreen extends ConsumerStatefulWidget {
  const DeliveryMissionDetailScreen({super.key, required this.missionId, required this.scope, this.feedItem});

  final String missionId;
  final DriverScope scope;
  final DriverWorkFeedItemDto? feedItem;

  @override
  ConsumerState<DeliveryMissionDetailScreen> createState() => _DeliveryMissionDetailScreenState();
}

class _DeliveryMissionDetailScreenState extends ConsumerState<DeliveryMissionDetailScreen> {
  bool _requestingOtp = false;
  bool _verifyingOtp = false;
  bool _completing = false;
  bool _submittingIncident = false;
  DeliveryHandoffOtpChallengeResponseDto? _challenge;
  String? _verifiedChallengeId;
  AppFailure? _otpFailure;
  AppFailure? _completeFailure;
  AppFailure? _incidentFailure;
  String? _completionIdempotencyKey;
  final _otpCodeController = TextEditingController();
  CreateDeliveryIncidentDtoType _incidentType = CreateDeliveryIncidentDtoType.delay;
  final _incidentCommentController = TextEditingController();

  @override
  void dispose() {
    _otpCodeController.dispose();
    _incidentCommentController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    setState(() {
      _requestingOtp = true;
      _otpFailure = null;
    });
    try {
      final challenge = await ref.read(deliveryRepositoryProvider).requestOtp(widget.missionId);
      if (mounted) setState(() => _challenge = challenge);
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _otpFailure = failure);
    } finally {
      if (mounted) setState(() => _requestingOtp = false);
    }
  }

  Future<void> _verifyOtp() async {
    final challenge = _challenge;
    if (challenge == null || _verifyingOtp) return;
    setState(() {
      _verifyingOtp = true;
      _otpFailure = null;
    });
    try {
      final result = await ref
          .read(deliveryRepositoryProvider)
          .verifyOtp(widget.missionId, challengeId: challenge.challengeId, code: _otpCodeController.text.trim());
      if (mounted) setState(() => _verifiedChallengeId = result.challengeId);
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _otpFailure = failure);
    } finally {
      if (mounted) setState(() => _verifyingOtp = false);
    }
  }

  Future<void> _complete() async {
    final challengeId = _verifiedChallengeId;
    if (challengeId == null || _completing) return;
    setState(() {
      _completing = true;
      _completeFailure = null;
    });
    // Held for the lifetime of this completion attempt and reused across
    // retries, never regenerated per HTTP call - see
    // core/utils/idempotency_key.dart.
    _completionIdempotencyKey ??= generateIdempotencyKey();
    try {
      await ref.read(deliveryRepositoryProvider).complete(
            widget.missionId,
            otpChallengeId: challengeId,
            idempotencyKey: _completionIdempotencyKey!,
          );
      _completionIdempotencyKey = null;
      ref.invalidate(missionDetailProvider(widget.missionId));
      // Targeted invalidation (mandate DRIVER-APP-04 §15/§16), not a
      // brute-force refresh: these are exactly the two providers Home's
      // "continue active work" card reads (see home_screen.dart) - without
      // this, a just-completed delivery kept showing as active work there
      // until an unrelated rebuild happened to drop the cached value.
      ref.invalidate(availabilityProvider(widget.scope));
      ref.invalidate(missionListByStatusProvider((widget.scope, 'OUT_FOR_DELIVERY')));
      // Work Feed reads a third, separate provider (mandate §15) - found via
      // real on-device testing: the first two alone left the just-completed
      // mission still showing "Out for delivery" in the Work Feed list.
      ref.invalidate(workFeedProvider(widget.scope));
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _completeFailure = failure);
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Future<void> _submitIncident() async {
    setState(() {
      _submittingIncident = true;
      _incidentFailure = null;
    });
    try {
      final comment = _incidentCommentController.text.trim();
      await ref
          .read(deliveryRepositoryProvider)
          .createIncident(widget.missionId, type: _incidentType, comment: comment.isEmpty ? null : comment);
      _incidentCommentController.clear();
      ref.invalidate(missionIncidentsProvider(widget.missionId));
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _incidentFailure = failure);
    } finally {
      if (mounted) setState(() => _submittingIncident = false);
    }
  }

  Future<void> _call(String phone) async {
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  Future<void> _navigate(num latitude, num longitude) async {
    await launchUrl(Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncMission = ref.watch(missionDetailProvider(widget.missionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.missionDetailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: l10n.missionMapTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DeliveryMissionMapScreen(missionId: widget.missionId, scope: widget.scope, feedItem: widget.feedItem),
              ),
            ),
          ),
        ],
      ),
      body: asyncMission.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          failure: error is AppFailure ? error : const AppFailure(AppFailureType.unknown),
          onRetry: () => ref.invalidate(missionDetailProvider(widget.missionId)),
        ),
        data: _buildContent,
      ),
    );
  }

  Widget _buildContent(DriverMissionResponseDto mission) {
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(missionDetailProvider(widget.missionId));
        ref.invalidate(missionIncidentsProvider(widget.missionId));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Header(mission: mission),
          const SizedBox(height: AppSpacing.lg),
          _Section(title: l10n.missionSectionPickup, child: _pickupContent()),
          const SizedBox(height: AppSpacing.lg),
          _Section(title: l10n.missionSectionDropoff, child: _dropoffContent(mission)),
          const SizedBox(height: AppSpacing.lg),
          _Section(title: l10n.missionSectionFinancial, child: _financialContent(mission)),
          const SizedBox(height: AppSpacing.lg),
          _Section(title: l10n.missionSectionMission, child: _missionContent(mission)),
          const SizedBox(height: AppSpacing.lg),
          _Section(title: l10n.missionSectionEvidence, child: _evidenceContent(mission)),
          const SizedBox(height: AppSpacing.lg),
          _Section(title: l10n.missionSectionIncidents, child: _incidentsContent()),
          const SizedBox(height: AppSpacing.lg),
          _actionsContent(mission),
        ],
      ),
    );
  }

  Widget _pickupContent() {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final pickup = widget.feedItem?.pickup;
    if (pickup == null || (pickup.label == null && pickup.addressLine1 == null)) {
      return Text(l10n.missionSectionNotAvailable, style: TextStyle(color: colors.textMuted));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pickup.label != null) Text(pickup.label!, style: Theme.of(context).textTheme.titleMedium),
        if (pickup.addressLine1 != null) Text(pickup.addressLine1!),
        if (pickup.latitude != null && pickup.longitude != null) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => _navigate(pickup.latitude!, pickup.longitude!),
            icon: const Icon(Icons.navigation_outlined, size: 18),
            label: Text(l10n.missionNavigateAction),
          ),
        ],
      ],
    );
  }

  Widget _dropoffContent(DriverMissionResponseDto mission) {
    final l10n = AppLocalizations.of(context);
    final dropoffCoords = widget.feedItem?.dropoff;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(mission.customerFullName, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(mission.addressLine1),
        if (mission.addressLine2 != null) Text(mission.addressLine2!),
        if (mission.instructions != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(mission.instructions!, style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (mission.customerPhone != null)
              OutlinedButton.icon(
                onPressed: () => _call(mission.customerPhone!),
                icon: const Icon(Icons.call_outlined, size: 18),
                label: Text(l10n.missionCallAction),
              ),
            if (dropoffCoords?.latitude != null && dropoffCoords?.longitude != null)
              OutlinedButton.icon(
                onPressed: () => _navigate(dropoffCoords!.latitude!, dropoffCoords.longitude!),
                icon: const Icon(Icons.navigation_outlined, size: 18),
                label: Text(l10n.missionNavigateAction),
              ),
          ],
        ),
      ],
    );
  }

  Widget _financialContent(DriverMissionResponseDto mission) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final codedAmount = widget.feedItem?.amount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.missionFinancialCodLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.textMuted)),
        const SizedBox(height: AppSpacing.xs),
        if (codedAmount != null)
          Text('${codedAmount.amount} ${codedAmount.currencyCode}', style: Theme.of(context).textTheme.headlineSmall)
        else ...[
          Text(mission.codExpectedAmount, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.missionFinancialNoCurrency, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textMuted)),
        ],
      ],
    );
  }

  Widget _missionContent(DriverMissionResponseDto mission) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final timestamps = <(String, String?)>[
      (l10n.missionTimestampAssigned, mission.assignedAt),
      (l10n.missionTimestampOutForDelivery, mission.outForDeliveryAt),
      (l10n.missionTimestampDelivered, mission.deliveredAt),
      (l10n.missionTimestampFailed, mission.failedAt),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusBadge(status: mission.status),
        const SizedBox(height: AppSpacing.md),
        for (final (label, value) in timestamps)
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.textMuted)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.missionLineItemsCount(mission.lines.length)),
      ],
    );
  }

  Widget _evidenceContent(DriverMissionResponseDto mission) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final challenge = _challenge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_verifiedChallengeId != null)
          Text(l10n.missionOtpVerifiedLabel, style: TextStyle(color: colors.success))
        else ...[
          if (challenge != null) ...[
            Text(l10n.missionOtpChallengeStatus(otpChallengeStatusLabel(l10n, challenge.status))),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _otpCodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              enabled: !_verifyingOtp,
              decoration: InputDecoration(labelText: l10n.missionOtpCodeLabel, counterText: ''),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: _verifyingOtp ? null : _verifyOtp,
              child: _verifyingOtp
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.missionOtpVerifyCta),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          ElevatedButton(
            onPressed: _requestingOtp ? null : _requestOtp,
            child: _requestingOtp
                ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colors.actionPrimaryInk))
                : Text(challenge == null ? l10n.missionOtpRequestCta : l10n.missionOtpRequestAgainCta),
          ),
        ],
        if (_otpFailure != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(localizeFailure(context, _otpFailure!), style: TextStyle(color: colors.danger)),
        ],
      ],
    );
  }

  Widget _incidentsContent() {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final asyncIncidents = ref.watch(missionIncidentsProvider(widget.missionId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        asyncIncidents.when(
          loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.sm), child: LinearProgressIndicator()),
          error: (error, _) => Text(
            error is AppFailure ? localizeFailure(context, error) : l10n.errorUnknown,
            style: TextStyle(color: colors.danger),
          ),
          data: (incidents) {
            if (incidents.isEmpty) {
              return Text(l10n.incidentsEmpty, style: TextStyle(color: colors.textMuted));
            }
            return Column(
              children: [
                for (final incident in incidents)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _IncidentTile(incident: incident),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<CreateDeliveryIncidentDtoType>(
          initialValue: _incidentType,
          // See the identical comment in mobility_incidents_section.dart -
          // an un-expanded dropdown sizes itself to its widest item.
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.incidentTypeLabel),
          items: [
            DropdownMenuItem(value: CreateDeliveryIncidentDtoType.delay, child: Text(l10n.incidentTypeDelay)),
            DropdownMenuItem(value: CreateDeliveryIncidentDtoType.vehicleIssue, child: Text(l10n.incidentTypeVehicleIssue)),
            DropdownMenuItem(value: CreateDeliveryIncidentDtoType.safety, child: Text(l10n.incidentTypeSafety)),
            DropdownMenuItem(value: CreateDeliveryIncidentDtoType.other, child: Text(l10n.incidentTypeOther)),
          ],
          onChanged: _submittingIncident ? null : (value) => setState(() => _incidentType = value ?? _incidentType),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _incidentCommentController,
          maxLength: 500,
          maxLines: 2,
          enabled: !_submittingIncident,
          decoration: InputDecoration(labelText: l10n.incidentCommentLabel),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: _submittingIncident ? null : _submitIncident,
          child: _submittingIncident
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.incidentSubmitCta),
        ),
        if (_incidentFailure != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(localizeFailure(context, _incidentFailure!), style: TextStyle(color: colors.danger)),
        ],
      ],
    );
  }

  Widget _actionsContent(DriverMissionResponseDto mission) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;

    if (mission.status == DriverMissionResponseDtoStatus.delivered) {
      return Text(l10n.missionAlreadyCompleted, style: TextStyle(color: colors.success));
    }
    if (mission.status != DriverMissionResponseDtoStatus.outForDelivery) {
      return Text(l10n.missionCompleteRequiresOutForDelivery, style: TextStyle(color: colors.textMuted));
    }

    final canComplete = _verifiedChallengeId != null && !_completing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: canComplete ? _complete : null,
          child: _completing
              ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.actionPrimaryInk))
              : Text(l10n.missionCompleteCta),
        ),
        if (_verifiedChallengeId == null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.missionCompleteRequiresOtp, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textMuted)),
        ],
        if (_completeFailure != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(localizeFailure(context, _completeFailure!), style: TextStyle(color: colors.danger)),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.mission});

  final DriverMissionResponseDto mission;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.local_shipping_outlined, color: colors.textSecondary, size: 28),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.workFeedTypeDelivery, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.textMuted)),
              Text('#${mission.shipmentId.substring(0, mission.shipmentId.length.clamp(0, 8))}', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        _StatusBadge(status: mission.status),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

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

class _IncidentTile extends StatelessWidget {
  const _IncidentTile({required this.incident});

  final DeliveryIncidentResponseDto incident;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final (label, background, foreground) = deliveryIncidentStatusPresentation(l10n, colors, incident.status);
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
                Text(deliveryIncidentTypeLabel(l10n, incident.type), style: Theme.of(context).textTheme.bodyMedium),
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
