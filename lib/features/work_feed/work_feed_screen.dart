import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/error_view.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../driver_context/driver_context_repository.dart';
import 'work_feed_repository.dart';

/// Foundation-only work feed: proves DELIVERY and RIDE work items can be
/// fetched and rendered from the same `/v1/driver/work-feed` boundary
/// without merging them into a UniversalOrder/UniversalMission - each item
/// still carries its own `underlyingResource.resourceType`. The full
/// mission workflow (accept/start/complete/POD/OTP/QR) is DRIVER-APP-03
/// scope, not this screen.
class WorkFeedScreen extends ConsumerWidget {
  const WorkFeedScreen({super.key, required this.scope});

  final DriverScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncFeed = ref.watch(workFeedProvider(scope));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.workFeedTitle)),
      body: asyncFeed.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          failure: error is AppFailure ? error : const AppFailure(AppFailureType.unknown),
          onRetry: () => ref.invalidate(workFeedProvider(scope)),
        ),
        data: (list) {
          if (list.items.isEmpty) {
            return EmptyView(
              icon: Icons.inbox_outlined,
              title: l10n.workFeedEmpty,
              body: l10n.workFeedEmptyBody,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(workFeedProvider(scope)),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: list.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => _WorkFeedTile(item: list.items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _WorkFeedTile extends StatelessWidget {
  const _WorkFeedTile({required this.item});

  final DriverWorkFeedItemDto item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final isDelivery = item.workType == DriverWorkFeedItemDtoWorkType.delivery;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isDelivery ? Icons.local_shipping_outlined : Icons.directions_car_filled_outlined,
              color: colors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDelivery ? l10n.workFeedTypeDelivery : l10n.workFeedTypeRide,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(item.status, style: Theme.of(context).textTheme.titleMedium),
                  if (item.dropoff?.addressLine1 != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(item.dropoff!.addressLine1!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  if (item.amount != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text('${item.amount!.amount} ${item.amount!.currencyCode}'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
