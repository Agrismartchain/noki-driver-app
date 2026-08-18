import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/connectivity/offline_banner.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/error_view.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../availability/availability_card.dart';
import '../vehicles/vehicles_screen.dart';
import '../work_feed/work_feed_repository.dart';
import 'driver_context_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncContext = ref.watch(driverContextProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: asyncContext.when(
              loading: () => const LoadingView(),
              error: (error, _) => ErrorView(
                failure: error is AppFailure ? error : const AppFailure(AppFailureType.unknown),
                onRetry: () => ref.invalidate(driverContextProvider),
              ),
              data: (context) => _HomeContent(context: context),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.context});

  final DriverContextResponseDto context;

  @override
  Widget build(BuildContext buildContext, WidgetRef ref) {
    final l10n = AppLocalizations.of(buildContext);
    final scope = activeScopeFrom(context);
    final profile = context.profiles.isNotEmpty ? context.profiles.first : null;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(driverContextProvider);
        if (scope != null) ref.invalidate(workFeedProvider(scope));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.homeGreeting(context.displayName), style: Theme.of(buildContext).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          if (profile != null && scope != null)
            _ProfileSummaryCard(
              profile: profile,
              onOpenVehicles: () => Navigator.of(buildContext).push(
                MaterialPageRoute(builder: (_) => VehiclesScreen(scope: scope)),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          if (scope != null) AvailabilityCard(scope: scope),
          const SizedBox(height: AppSpacing.lg),
          if (scope != null) _WorkFeedSummaryCard(scope: scope),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.profile, required this.onOpenVehicles});

  final DriverContextProfileDto profile;
  final VoidCallback onOpenVehicles;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final vehicle = profile.assignedVehicle;

    return Card(
      child: InkWell(
        onTap: onOpenVehicles,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(label: l10n.homeCountryLabel, value: profile.countryCode),
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                label: l10n.homeCapabilitiesLabel,
                value: profile.serviceTypes.map((s) => s.name.toUpperCase()).join(' · '),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.homeVehicleLabel, style: Theme.of(context).textTheme.labelSmall),
                  Icon(Icons.chevron_right, size: 18, color: colors.textMuted),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              if (vehicle == null)
                Text(l10n.homeNoVehicle, style: TextStyle(color: colors.textMuted))
              else
                Text('${vehicle.make} ${vehicle.model} · ${vehicle.plate}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _WorkFeedSummaryCard extends ConsumerWidget {
  const _WorkFeedSummaryCard({required this.scope});

  final DriverScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncFeed = ref.watch(workFeedProvider(scope));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.homeWorkFeedSummaryTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            asyncFeed.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text(l10n.errorUnknown),
              data: (feed) => Text(l10n.homeWorkFeedSummaryCount(feed.total.toInt())),
            ),
          ],
        ),
      ),
    );
  }
}
