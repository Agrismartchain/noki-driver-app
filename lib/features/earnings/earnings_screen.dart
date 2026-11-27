import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/finance/driver_finance_models.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/error_view.dart';
import '../../core/errors/failure_localizer.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/noki_finance.dart';
import '../../core/ui/noki_ui.dart';
import '../driver_context/driver_context_repository.dart';
import 'earnings_providers.dart';

enum _EarningsSectionTab { missions, payouts, cod }

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key, required this.scope});

  final DriverScope scope;

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  _EarningsSectionTab _activeTab = _EarningsSectionTab.missions;
  bool _submittingCancel = false;

  Future<void> _refresh() async {
    ref.invalidate(driverEarningsSnapshotProvider(widget.scope));
    try {
      await ref.read(driverEarningsSnapshotProvider(widget.scope).future);
    } catch (_) {
      // AsyncValue.error renders the appropriate unavailable or retry view.
    }
  }

  Future<void> _openRequestPayoutSheet(DriverEarningsSnapshot snapshot) async {
    final l10n = AppLocalizations.of(context);
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _RequestPayoutSheet(
        scope: widget.scope,
        eligibility: snapshot.eligibility,
      ),
    );
    if (submitted == true && mounted) {
      ref.invalidate(driverEarningsSnapshotProvider(widget.scope));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.earningsPayoutSuccessMessage)),
      );
    }
  }

  Future<void> _cancelPayout(DriverPayoutItemDto payout) async {
    if (_submittingCancel) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _submittingCancel = true);
    try {
      await ref
          .read(driverApiClientProvider)
          .cancelDriverPayout(
            payoutId: payout.id,
            organizationId: widget.scope.organizationId,
            countryCode: widget.scope.countryCode,
            reason: 'Cancelled by driver in mobile app',
            idempotencyKey: generateDriverIdempotencyKey('driver-cancel'),
          );
      if (!mounted) return;
      ref.invalidate(driverEarningsSnapshotProvider(widget.scope));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.earningsPayoutCancelledMessage)),
      );
    } on AppFailure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizeFailure(context, failure))),
      );
    } finally {
      if (mounted) setState(() => _submittingCancel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncSnapshot = ref.watch(driverEarningsSnapshotProvider(widget.scope));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.earningsTitle),
        actions: [
          IconButton(
            tooltip: l10n.actionRetry,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: NokiScreenBackground(
        child: asyncSnapshot.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) {
            final failure = error is AppFailure
                ? error
                : const AppFailure(AppFailureType.unknown);
            if (failure.type == AppFailureType.notFound ||
                failure.type == AppFailureType.forbidden) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  key: const Key('earnings-unavailable-view'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.xxl,
                    AppSpacing.page,
                    AppSpacing.xxl,
                  ),
                  children: [
                    EmptyView(
                      icon: Icons.account_balance_wallet_outlined,
                      title: l10n.earningsUnavailableTitle,
                      body: l10n.earningsUnavailableBody,
                    ),
                  ],
                ),
              );
            }
            return ErrorView(failure: failure, onRetry: _refresh);
          },
          data: (snapshot) => _buildContent(context, l10n, snapshot),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    DriverEarningsSnapshot snapshot,
  ) {
    final summary = snapshot.summary;
    final cod = summary.codSummary;
    final currency = summary.currencyCode;
    final isAllZero =
        summary.availableAmount == '0' &&
        summary.pendingPayoutAmount == '0' &&
        summary.paidAmount == '0' &&
        summary.onHoldAmount == '0';

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        key: const Key('earnings-scroll-view'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          AppSpacing.xxl,
        ),
        children: [
          NokiFinanceCallout(
            key: const Key('earnings-available-callout'),
            label: l10n.earningsAvailableLabel,
            amount: summary.availableAmount,
            currencyCode: currency,
            icon: Icons.account_balance_wallet_outlined,
            tone: NokiFinanceTone.earnings,
            caption: isAllZero
                ? l10n.earningsZeroHint
                : summary.defaultPaymentMethodMasked != null
                ? '${l10n.earningsPayoutDestinationLabel}: ${summary.defaultPaymentMethodMasked}'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('earnings-request-payout-button'),
              onPressed: () => _openRequestPayoutSheet(snapshot),
              icon: const Icon(Icons.payments_outlined),
              label: Text(l10n.earningsRequestPayoutButton),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _BalanceStatCard(
                  cardKey: const Key('earnings-pending-card'),
                  label: l10n.earningsPendingLabel,
                  amount: formatNokiMoney(
                    summary.pendingPayoutAmount,
                    currencyCode: currency,
                  ),
                  tone: NokiBadgeTone.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _BalanceStatCard(
                  cardKey: const Key('earnings-paid-card'),
                  label: l10n.earningsPaidLabel,
                  amount: formatNokiMoney(
                    summary.paidAmount,
                    currencyCode: currency,
                  ),
                  tone: NokiBadgeTone.success,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _BalanceStatCard(
                  cardKey: const Key('earnings-onhold-card'),
                  label: l10n.earningsOnHoldLabel,
                  amount: formatNokiMoney(
                    summary.onHoldAmount,
                    currencyCode: currency,
                  ),
                  tone: NokiBadgeTone.danger,
                ),
              ),
            ],
          ),
          if (summary.missingRemunerationRuleServices.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            NokiOperationalBanner(
              key: const Key('earnings-missing-rules-banner'),
              icon: Icons.info_outline,
              message: l10n.earningsRulesMissingNotice(
                summary.missingRemunerationRuleServices
                    .map((s) => _serviceLabel(l10n, s))
                    .join(', '),
              ),
              tone: NokiBadgeTone.info,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          // Strictly separated COD cash section (never mixed with driver earnings).
          NokiFinanceCallout(
            key: const Key('earnings-cod-callout'),
            label: l10n.earningsCodSectionTitle,
            amount: cod.toRemitAmount,
            currencyCode: cod.currencyCode,
            icon: Icons.point_of_sale_outlined,
            tone: NokiFinanceTone.cod,
            caption:
                '${l10n.earningsCodToRemitLabel}: ${formatNokiMoney(cod.toRemitAmount, currencyCode: cod.currencyCode)} · '
                '${l10n.earningsCodRemittedLabel}: ${formatNokiMoney(cod.remittedAmount, currencyCode: cod.currencyCode)} · '
                '${l10n.earningsCodReconciledLabel}: ${formatNokiMoney(cod.reconciledAmount, currencyCode: cod.currencyCode)}',
          ),
          const SizedBox(height: AppSpacing.sm),
          NokiFinanceNotice(
            message: l10n.earningsCodSeparationNotice,
            tone: NokiBadgeTone.warning,
          ),
          const SizedBox(height: AppSpacing.xl),
          SegmentedButton<_EarningsSectionTab>(
            key: const Key('earnings-section-switcher'),
            segments: [
              ButtonSegment(
                value: _EarningsSectionTab.missions,
                label: Text(l10n.earningsTabMissions),
              ),
              ButtonSegment(
                value: _EarningsSectionTab.payouts,
                label: Text(l10n.earningsTabPayouts),
              ),
              ButtonSegment(
                value: _EarningsSectionTab.cod,
                label: Text(l10n.earningsTabCod),
              ),
            ],
            selected: {_activeTab},
            onSelectionChanged: (selection) =>
                setState(() => _activeTab = selection.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...switch (_activeTab) {
            _EarningsSectionTab.missions => _buildEarningsList(
              context,
              l10n,
              snapshot.earnings,
            ),
            _EarningsSectionTab.payouts => _buildPayoutsList(
              context,
              l10n,
              snapshot.payouts,
            ),
            _EarningsSectionTab.cod => _buildCodList(
              context,
              l10n,
              snapshot.codCollections,
            ),
          },
        ],
      ),
    );
  }

  List<Widget> _buildEarningsList(
    BuildContext context,
    AppLocalizations l10n,
    List<DriverEarningItemDto> items,
  ) {
    if (items.isEmpty) {
      return [
        EmptyView(
          icon: Icons.receipt_long_outlined,
          title: l10n.earningsEmptyMissionsTitle,
          body: l10n.earningsEmptyMissionsBody,
        ),
      ];
    }
    return [
      for (final item in items) ...[
        NokiSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NokiBadge(
                    label: _serviceLabel(l10n, item.serviceCode),
                    tone: NokiBadgeTone.info,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (item.direction == 'RECEIVABLE')
                    NokiBadge(
                      label: l10n.earningsObligationReceivableTag,
                      tone: NokiBadgeTone.warning,
                    )
                  else
                    NokiBadge(
                      label: _obligationStatusLabel(l10n, item.status),
                      tone: _obligationStatusTone(item.status),
                    ),
                  const Spacer(),
                  Text(
                    formatNokiMoney(
                      item.originalAmount,
                      currencyCode: item.currencyCode,
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: item.direction == 'RECEIVABLE'
                          ? context.nokiColors.warning
                          : context.nokiColors.financePositive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.earningsMissionRefLabel(_shortRef(item.sourceReferenceId)),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (item.createdAt.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _shortDate(item.createdAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    ];
  }

  List<Widget> _buildPayoutsList(
    BuildContext context,
    AppLocalizations l10n,
    List<DriverPayoutItemDto> items,
  ) {
    if (items.isEmpty) {
      return [
        EmptyView(
          icon: Icons.payments_outlined,
          title: l10n.earningsEmptyPayoutsTitle,
          body: l10n.earningsEmptyPayoutsBody,
        ),
      ];
    }
    return [
      for (final payout in items) ...[
        NokiSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      payout.code,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    formatNokiMoney(
                      payout.totalAmount,
                      currencyCode: payout.currencyCode,
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  NokiBadge(
                    label: _payoutStatusLabel(l10n, payout.status),
                    tone: _payoutStatusTone(payout.status),
                  ),
                  if (payout.destinationMasked != null)
                    NokiBadge(
                      label: payout.destinationMasked!,
                      tone: NokiBadgeTone.neutral,
                    ),
                ],
              ),
              if (payout.createdAt.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _shortDate(payout.createdAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
              if (payout.status == 'PENDING_FIRST_APPROVAL') ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton(
                    onPressed: _submittingCancel
                        ? null
                        : () => _cancelPayout(payout),
                    child: Text(l10n.earningsPayoutCancelButton),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    ];
  }

  List<Widget> _buildCodList(
    BuildContext context,
    AppLocalizations l10n,
    List<DriverCodCollectionItemDto> items,
  ) {
    if (items.isEmpty) {
      return [
        EmptyView(
          icon: Icons.point_of_sale_outlined,
          title: l10n.earningsEmptyCodTitle,
          body: l10n.earningsEmptyCodBody,
        ),
      ];
    }
    return [
      for (final item in items) ...[
        NokiSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NokiBadge(
                    label: _codStatusLabel(l10n, item.status),
                    tone: _codStatusTone(item.status),
                  ),
                  const Spacer(),
                  Text(
                    formatNokiMoney(
                      item.collectedAmount,
                      currencyCode: item.currencyCode,
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.earningsMissionRefLabel(_shortRef(item.orderId)),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (item.declaredAt.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _shortDate(item.declaredAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    ];
  }
}

class _BalanceStatCard extends StatelessWidget {
  const _BalanceStatCard({
    this.cardKey,
    required this.label,
    required this.amount,
    required this.tone,
  });

  final Key? cardKey;
  final String label;
  final String amount;
  final NokiBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final accent = switch (tone) {
      NokiBadgeTone.success => colors.success,
      NokiBadgeTone.warning => colors.warning,
      NokiBadgeTone.danger => colors.danger,
      _ => colors.textPrimary,
    };
    return NokiSurfaceCard(
      key: cardKey,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestPayoutSheet extends ConsumerStatefulWidget {
  const _RequestPayoutSheet({
    required this.scope,
    required this.eligibility,
  });

  final DriverScope scope;
  final DriverPayoutEligibilityDto eligibility;

  @override
  ConsumerState<_RequestPayoutSheet> createState() =>
      _RequestPayoutSheetState();
}

class _RequestPayoutSheetState extends ConsumerState<_RequestPayoutSheet> {
  // Single idempotency key per confirmation sheet instance so retrying after a
  // transient network timeout never duplicates the payout request.
  late final String _idempotencyKey = generateDriverIdempotencyKey(
    'driver-payout',
  );
  bool _submitting = false;
  String? _errorMessage;

  Future<void> _confirm() async {
    if (_submitting || !widget.eligibility.eligible) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(driverApiClientProvider)
          .requestDriverPayout(
            organizationId: widget.scope.organizationId,
            countryCode: widget.scope.countryCode,
            idempotencyKey: _idempotencyKey,
            paymentMethodId: widget.eligibility.defaultPaymentMethodId,
            obligationIds: widget.eligibility.eligibleObligationIds,
            requestedAmount: widget.eligibility.availableAmount,
          );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on AppFailure catch (failure) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _errorMessage = localizeFailure(context, failure);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final e = widget.eligibility;
    final colors = context.nokiColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.earningsPayoutSheetTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            NokiFinanceCallout(
              label: l10n.earningsPayoutEligibleAmount,
              amount: e.availableAmount,
              currencyCode: e.currencyCode,
              icon: Icons.payments_outlined,
              tone: NokiFinanceTone.earnings,
              caption: e.defaultPaymentMethodMasked != null
                  ? '${l10n.earningsPayoutDestinationLabel}: ${e.defaultPaymentMethodMasked}'
                  : l10n.earningsPayoutNoMethod,
            ),
            if (e.blockers.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              for (final blocker in e.blockers) ...[
                NokiOperationalBanner(
                  icon: Icons.warning_amber_rounded,
                  message: blocker.message,
                  tone: NokiBadgeTone.warning,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              NokiOperationalBanner(
                icon: Icons.error_outline,
                message: _errorMessage!,
                tone: NokiBadgeTone.danger,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              key: const Key('payout-confirm-button'),
              onPressed: (!e.eligible || _submitting) ? null : _confirm,
              child: _submitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.actionPrimaryInk,
                      ),
                    )
                  : Text(l10n.earningsPayoutConfirmButton),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: _submitting
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(l10n.settingsCancel),
            ),
          ],
        ),
      ),
    );
  }
}

String _serviceLabel(AppLocalizations l10n, String code) {
  return switch (code.toUpperCase()) {
    'TAXI' => l10n.serviceTypeTaxi,
    'TAXI_MOTO' => l10n.serviceTypeTaxiMoto,
    'COURIER' => l10n.serviceTypeCourier,
    'CARGO' => l10n.serviceTypeCargo,
    'DELIVERY' => l10n.workFeedTypeDelivery,
    _ => code,
  };
}

String _obligationStatusLabel(AppLocalizations l10n, String status) {
  return switch (status) {
    'OPEN' => l10n.earningsObligationStatusOpen,
    'ALLOCATED' || 'PARTIALLY_ALLOCATED' =>
      l10n.earningsObligationStatusAllocated,
    'SETTLED' || 'PARTIALLY_SETTLED' => l10n.earningsObligationStatusSettled,
    'ON_HOLD' => l10n.earningsObligationStatusOnHold,
    _ => status,
  };
}

NokiBadgeTone _obligationStatusTone(String status) {
  return switch (status) {
    'OPEN' => NokiBadgeTone.success,
    'ALLOCATED' || 'PARTIALLY_ALLOCATED' => NokiBadgeTone.warning,
    'SETTLED' || 'PARTIALLY_SETTLED' => NokiBadgeTone.info,
    'ON_HOLD' => NokiBadgeTone.danger,
    _ => NokiBadgeTone.neutral,
  };
}

String _payoutStatusLabel(AppLocalizations l10n, String status) {
  return switch (status) {
    'DRAFT' ||
    'PROPOSED' ||
    'PENDING_FIRST_APPROVAL' ||
    'PENDING_FINAL_APPROVAL' => l10n.earningsPayoutStatusPending,
    'APPROVED' || 'EXPORT_READY' => l10n.earningsPayoutStatusApproved,
    'SENT' => l10n.earningsPayoutStatusSent,
    'PAID' || 'MARKED_PAID' || 'RECONCILED' => l10n.earningsPayoutStatusPaid,
    'ON_HOLD' => l10n.earningsPayoutStatusOnHold,
    'FAILED' => l10n.earningsPayoutStatusFailed,
    'CANCELLED' => l10n.earningsPayoutStatusCancelled,
    _ => status,
  };
}

NokiBadgeTone _payoutStatusTone(String status) {
  return switch (status) {
    'PAID' || 'MARKED_PAID' || 'RECONCILED' => NokiBadgeTone.success,
    'APPROVED' || 'EXPORT_READY' || 'SENT' => NokiBadgeTone.info,
    'ON_HOLD' || 'FAILED' => NokiBadgeTone.danger,
    'CANCELLED' => NokiBadgeTone.neutral,
    _ => NokiBadgeTone.warning,
  };
}

String _codStatusLabel(AppLocalizations l10n, String status) {
  return switch (status) {
    'DECLARED' => l10n.earningsCodStatusDeclared,
    'REMITTED' => l10n.earningsCodStatusRemitted,
    'RECONCILED' => l10n.earningsCodStatusReconciled,
    'VOIDED' => l10n.earningsCodStatusVoided,
    _ => status,
  };
}

NokiBadgeTone _codStatusTone(String status) {
  return switch (status) {
    'DECLARED' => NokiBadgeTone.warning,
    'REMITTED' => NokiBadgeTone.info,
    'RECONCILED' => NokiBadgeTone.success,
    _ => NokiBadgeTone.neutral,
  };
}

String _shortRef(String ref) => ref.length > 10 ? ref.substring(0, 10) : ref;

String _shortDate(String iso) => iso.length >= 10 ? iso.substring(0, 10) : iso;
