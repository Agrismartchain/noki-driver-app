import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
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
import '../mobility/mobility_ride_screen.dart';
import '../mobility/mobility_work_card.dart';
import 'work_feed_repository.dart';

enum _WorkFeedFilter { all, delivery, rides, active, pending }

/// The unified operational Work screen: real Delivery and Mobility items
/// from `/v1/driver/work-feed`, rendered with typed, visually distinct
/// cards and routed to the correct domain-specific detail screen on tap -
/// never merged into a single generic "order" shape (mandate §3/§12/§13).
/// Filters operate on the already-loaded page only; no server filtering
/// parameter is invented (§16).
class WorkFeedScreen extends ConsumerStatefulWidget {
  const WorkFeedScreen({super.key, required this.scope});

  final DriverScope scope;

  @override
  ConsumerState<WorkFeedScreen> createState() => _WorkFeedScreenState();
}

class _WorkFeedScreenState extends ConsumerState<WorkFeedScreen> {
  _WorkFeedFilter _filter = _WorkFeedFilter.all;

  List<DriverWorkFeedItemDto> _applyFilter(List<DriverWorkFeedItemDto> items) {
    switch (_filter) {
      case _WorkFeedFilter.all:
        return items;
      case _WorkFeedFilter.delivery:
        return items
            .where((i) => i.workType == DriverWorkFeedItemDtoWorkType.delivery)
            .toList();
      case _WorkFeedFilter.rides:
        return items
            .where((i) => i.workType == DriverWorkFeedItemDtoWorkType.ride)
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final filter in _WorkFeedFilter.values) ...[
                    ChoiceChip(
                      label: Text(_filterLabel(l10n, filter)),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: asyncFeed.when(
              loading: () => const LoadingView(),
              error: (error, _) => ErrorView(
                failure: error is AppFailure
                    ? error
                    : const AppFailure(AppFailureType.unknown),
                onRetry: () => ref.invalidate(workFeedProvider(widget.scope)),
              ),
              data: (list) {
                final filtered = _applyFilter(list.items);
                if (filtered.isEmpty) {
                  return EmptyView(
                    icon: Icons.inbox_outlined,
                    title: l10n.workFeedEmpty,
                    body: l10n.workFeedEmptyBody,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(workFeedProvider(widget.scope)),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
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
      _WorkFeedFilter.rides => l10n.workFeedFilterRides,
      _WorkFeedFilter.active => l10n.workFeedFilterActive,
      _WorkFeedFilter.pending => l10n.workFeedFilterPending,
    };
  }
}
