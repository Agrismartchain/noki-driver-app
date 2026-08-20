import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/error_view.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../driver_context/driver_context_repository.dart';
import 'delivery_mission_detail_screen.dart';
import 'delivery_repository.dart';

/// Completed-Delivery history (mandate §42). Reuses the already-wired
/// `listOwnMissions` with a `status=DELIVERED` filter - no new endpoint.
/// Mobility has no equivalent read (no completed-ride list endpoint exists
/// for a driver), so there is no Mobility history tab; that gap is reported,
/// not faked.
class DeliveryHistoryScreen extends ConsumerWidget {
  const DeliveryHistoryScreen({super.key, required this.scope});

  final DriverScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (scope, 'DELIVERED');
    final asyncMissions = ref.watch(missionListByStatusProvider(key));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deliveryHistoryTitle)),
      body: asyncMissions.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          failure: error is AppFailure
              ? error
              : const AppFailure(AppFailureType.unknown),
          onRetry: () => ref.invalidate(missionListByStatusProvider(key)),
        ),
        data: (list) {
          if (list.items.isEmpty) {
            return EmptyView(
              icon: Icons.history,
              title: l10n.deliveryHistoryEmpty,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: list.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final mission = list.items[index];
              return _HistoryTile(
                mission: mission,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DeliveryMissionDetailScreen(
                      missionId: mission.id,
                      scope: scope,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.mission, required this.onTap});

  final DriverMissionResponseDto mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: colors.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.customerFullName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (mission.deliveredAt != null)
                      Text(
                        mission.deliveredAt!,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.textMuted),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
