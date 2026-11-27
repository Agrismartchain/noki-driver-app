import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/connectivity/offline_banner.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/error_view.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../delivery/delivery_history_screen.dart';
import '../delivery/delivery_mission_detail_screen.dart';
import '../delivery/delivery_qr_scan_screen.dart';
import '../delivery/delivery_work_card.dart';
import '../driver_context/driver_context_repository.dart';
import '../mobility/mobility_offer_detail_screen.dart';
import '../mobility/mobility_offer_poller.dart';
import '../mobility/mobility_ride_screen.dart';
import '../mobility/mobility_work_card.dart';
import 'work_feed_repository.dart';

enum _WorkFeedFilter {
  all,
  delivery,
  taxi,
  taxiMoto,
  parcel,
  cargo,
  active,
  pending,
}

/// The unified operational Work screen: real Delivery and Mobility items
/// from `/v1/driver/work-feed`, rendered with typed, visually distinct
/// cards and routed to the correct domain-specific detail screen on tap -
/// never merged into a single generic "order" shape.
/// Filters operate on the already-loaded page only; no server filtering
/// parameter is invented.
class WorkFeedScreen extends ConsumerStatefulWidget {
  const WorkFeedScreen({super.key, required this.scope});

  final DriverScope scope;

  @override
  ConsumerState<WorkFeedScreen> createState() => _WorkFeedScreenState();
}

class _WorkFeedScreenState extends ConsumerState<WorkFeedScreen> {
  _WorkFeedFilter _filter = _WorkFeedFilter.all;

  // Captured once so `dispose()` can stop the timer without touching `ref`
  // (Riverpod forbids `ref.read`/`ref.watch` once the element is being
  // unmounted).
  late final MobilityOfferPollerController _offerPoller;

  @override
  void initState() {
    super.initState();
    _offerPoller = ref.read(mobilityOfferPollerControllerProvider);
    _offerPoller.start(widget.scope);
  }

  @override
  void didUpdateWidget(covariant WorkFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scope != widget.scope) {
      _offerPoller.start(widget.scope);
    }
  }

  @override
  void dispose() {
    _offerPoller.stop();
    super.dispose();
  }

  List<DriverWorkFeedItemDto> _applyFilter(List<DriverWorkFeedItemDto> items) {
    switch (_filter) {
      case _WorkFeedFilter.all:
        return items;
      case _WorkFeedFilter.delivery:
        return items
            .where((i) => i.workType == DriverWorkFeedItemDtoWorkType.delivery)
            .toList();
      case _WorkFeedFilter.taxi:
        return items
            .where((i) => i.serviceType == DriverWorkFeedItemDtoServiceType.taxi)
            .toList();
      case _WorkFeedFilter.taxiMoto:
        return items
            .where(
              (i) => i.serviceType == DriverWorkFeedItemDtoServiceType.taxiMoto,
            )
            .toList();
      case _WorkFeedFilter.parcel:
        return items
            .where(
              (i) =>
                  i.serviceType == DriverWorkFeedItemDtoServiceType.courier ||
                  i.serviceType == DriverWorkFeedItemDtoServiceType.delivery ||
                  i.workType == DriverWorkFeedItemDtoWorkType.delivery,
            )
            .toList();
      case _WorkFeedFilter.cargo:
        return items
            .where(
              (i) => i.serviceType == DriverWorkFeedItemDtoServiceType.cargo,
            )
            .toList();
      case _WorkFeedFilter.active:
        return items
            .where(
              (i) =>
                  i.sourceDomain != 'MOBILITY_OFFER' &&
                  i.status != 'DELIVERED' &&
                  i.status != 'CANCELLED' &&
                  i.status != 'COMPLETED',
            )
            .toList();
      case _WorkFeedFilter.pending:
        return items
            .where(
              (i) =>
                  i.sourceDomain == 'MOBILITY_OFFER' ||
                  i.status == 'ASSIGNED' ||
                  i.status == 'READY_FOR_DISPATCH',
            )
            .toList();
    }
  }

  void _open(DriverWorkFeedItemDto item) {
    final resource = item.underlyingResource;
    switch (resource.resourceType) {
      case 'DeliveryShipment':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DeliveryMissionDetailScreen(
              missionId: resource.resourceId,
              scope: widget.scope,
              feedItem: item,
            ),
          ),
        );
      case 'MobilityRideOffer':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MobilityOfferDetailScreen.fromWorkFeedItem(
              item: item,
              scope: widget.scope,
            ),
          ),
        );
      case 'MobilityRide':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MobilityRideScreen(
              rideId: resource.resourceId,
              scope: widget.scope,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncFeed = ref.watch(workFeedProvider(widget.scope));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workFeedTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_outlined),
            tooltip: l10n.qrScanTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DeliveryQrScanScreen(scope: widget.scope),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.deliveryHistoryTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DeliveryHistoryScreen(scope: widget.scope),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          SizedBox(
            height: 56,
            child: ListView.separated(
              key: const Key('work-feed-filter-bar'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              itemCount: _WorkFeedFilter.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final filter = _WorkFeedFilter.values[index];
                final label = _filterLabel(l10n, filter);
                return Semantics(
                  button: true,
                  selected: _filter == filter,
                  label: label,
                  child: ChoiceChip(
                    key: Key('work-filter-${filter.name}'),
                    label: Text(label),
                    selected: _filter == filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: asyncFeed.when(
              loading: () => const LoadingView(),
              error: (error, _) {
                final failure = error is AppFailure
                    ? error
                    : const AppFailure(AppFailureType.unknown);
                if (failure.type == AppFailureType.forbidden) {
                  return EmptyView(
                    icon: Icons.lock_outline,
                    title: l10n.workFeedAccessUnavailableTitle,
                    body: l10n.workFeedAccessUnavailableBody,
                  );
                }
                return ErrorView(
                  failure: failure,
                  onRetry: () => ref.invalidate(workFeedProvider(widget.scope)),
                );
              },
              data: (list) {
                if (list.items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(workFeedProvider(widget.scope)),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        EmptyView(
                          icon: Icons.inbox_outlined,
                          title: l10n.workFeedEmpty,
                          body: l10n.workFeedEmptyBody,
                        ),
                      ],
                    ),
                  );
                }
                final filtered = _applyFilter(list.items);
                if (filtered.isEmpty) {
                  return EmptyView(
                    icon: Icons.filter_list_off_outlined,
                    title: l10n.workFeedFilterEmptyTitle,
                    body: l10n.workFeedEmptyBody,
                    action: OutlinedButton(
                      onPressed: () =>
                          setState(() => _filter = _WorkFeedFilter.all),
                      child: Text(l10n.workFeedFilterReset),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(workFeedProvider(widget.scope)),
                  child: ListView.separated(
                    key: const Key('work-feed-list'),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return item.workType ==
                              DriverWorkFeedItemDtoWorkType.delivery
                          ? DeliveryWorkCard(
                              item: item,
                              onTap: () => _open(item),
                            )
                          : MobilityWorkCard(
                              item: item,
                              onTap: () => _open(item),
                            );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(AppLocalizations l10n, _WorkFeedFilter filter) {
    return switch (filter) {
      _WorkFeedFilter.all => l10n.workFeedFilterAll,
      _WorkFeedFilter.delivery => l10n.workFeedFilterDelivery,
      _WorkFeedFilter.taxi => l10n.workFeedFilterTaxi,
      _WorkFeedFilter.taxiMoto => l10n.workFeedFilterTaxiMoto,
      _WorkFeedFilter.parcel => l10n.workFeedFilterParcel,
      _WorkFeedFilter.cargo => l10n.workFeedFilterCargo,
      _WorkFeedFilter.active => l10n.workFeedFilterActive,
      _WorkFeedFilter.pending => l10n.workFeedFilterPending,
    };
  }
}
