import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/error_view.dart';
import '../../core/errors/failure_localizer.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../driver_context/driver_context_repository.dart';
import '../work_feed/work_feed_repository.dart';
import 'mobility_repository.dart';
import 'mobility_ride_screen.dart';
import 'mobility_status_presentation.dart';

/// Resolves an offer id (all the Work Feed card has -
/// `underlyingResource.resourceId`) against the real offers list - there is
/// no GET-by-id-offer endpoint, so this is the only honest way to reach an
/// offer's detail from the feed. If the offer is no longer in the list
/// (expired/superseded/accepted elsewhere between the feed load and the
/// tap), this shows a real empty state instead of a stale or fabricated one.
class MobilityOfferLookupScreen extends ConsumerWidget {
  const MobilityOfferLookupScreen({super.key, required this.offerId, required this.scope});

  final String offerId;
  final DriverScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncOffers = ref.watch(mobilityOffersProvider(scope));

    return asyncOffers.when(
      loading: () => Scaffold(appBar: AppBar(title: Text(l10n.mobilityOfferDetailTitle)), body: const LoadingView()),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.mobilityOfferDetailTitle)),
        body: ErrorView(
          failure: error is AppFailure ? error : const AppFailure(AppFailureType.unknown),
          onRetry: () => ref.invalidate(mobilityOffersProvider(scope)),
        ),
      ),
      data: (list) {
        DriverMobilityOfferDto? offer;
        for (final candidate in list.items) {
          if (candidate.id == offerId) {
            offer = candidate;
            break;
          }
        }
        if (offer == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.mobilityOfferDetailTitle)),
            body: EmptyView(icon: Icons.local_taxi_outlined, title: l10n.mobilityOfferNoLongerAvailable),
          );
        }
        return MobilityOfferDetailScreen(offer: offer, scope: scope);
      },
    );
  }
}

/// Offer detail + Accept, backed directly by the `DriverMobilityOfferDto`
/// the caller already has from the offers list - there is no
/// GET-by-id-offer endpoint to refresh from, so this screen does not read a
/// provider for the offer itself (only the mutation is state-managed).
class MobilityOfferDetailScreen extends ConsumerStatefulWidget {
  const MobilityOfferDetailScreen({super.key, required this.offer, required this.scope});

  final DriverMobilityOfferDto offer;
  final DriverScope scope;

  @override
  ConsumerState<MobilityOfferDetailScreen> createState() => _MobilityOfferDetailScreenState();
}

class _MobilityOfferDetailScreenState extends ConsumerState<MobilityOfferDetailScreen> {
  bool _accepting = false;
  AppFailure? _failure;

  Future<void> _accept() async {
    if (_accepting) return;
    setState(() {
      _accepting = true;
      _failure = null;
    });
    try {
      final ride = await ref.read(mobilityRepositoryProvider).acceptOffer(widget.offer.id);
      ref.invalidate(mobilityOffersProvider(widget.scope));
      ref.invalidate(currentRideProvider(widget.scope));
      ref.invalidate(workFeedProvider(widget.scope));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MobilityRideScreen(rideId: ride.id, scope: widget.scope)),
      );
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final offer = widget.offer;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mobilityOfferDetailTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              Icon(
                offer.serviceType == DriverMobilityOfferDtoServiceType.taxiMoto ? Icons.moped_outlined : Icons.local_taxi_outlined,
                color: colors.actionPrimary,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(offerServiceTypeLabel(l10n, offer.serviceType), style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoutePoint(icon: Icons.trip_origin, label: l10n.missionSectionPickup, address: offer.pickupAddressSnapshot),
                  const SizedBox(height: AppSpacing.md),
                  _RoutePoint(icon: Icons.place_outlined, label: l10n.missionSectionDropoff, address: offer.dropoffAddressSnapshot),
                  if (offer.estimatedFare != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(l10n.mobilityEstimatedFareLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.textMuted)),
                    Text(
                      '${offer.estimatedFare!.amount} ${offer.estimatedFare!.currencyCode}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: _accepting ? null : _accept,
            child: _accepting
                ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.actionPrimaryInk))
                : Text(l10n.mobilityAcceptOfferCta),
          ),
          if (_failure != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(localizeFailure(context, _failure!), style: TextStyle(color: colors.danger)),
          ],
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({required this.icon, required this.label, required this.address});

  final IconData icon;
  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.textMuted)),
              Text(address, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
