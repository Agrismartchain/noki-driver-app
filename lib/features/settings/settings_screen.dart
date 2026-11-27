import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/driver_models.generated.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/i18n/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/ui/noki_ui.dart';
import '../auth/auth_providers.dart';
import '../delivery/delivery_history_screen.dart';
import '../driver_context/driver_context_repository.dart';
import '../mobility/mobility_history_screen.dart';
import '../profile/driver_avatar_sheet.dart';
import '../vehicles/vehicles_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider) ?? defaultLocale;
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authControllerProvider);
    final driverContext = authState.driverContext;
    final avatarUrl = authState.avatarUrl;
    final profile = driverContext == null || driverContext.profiles.isEmpty
        ? null
        : driverContext.profiles.first;
    final scope = driverContext == null ? null : activeScopeFrom(driverContext);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: NokiScreenBackground(
        child: ListView(
          key: const Key('profile-scroll-view'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.xxl,
          ),
          children: [
            if (driverContext != null) ...[
              _DriverIdentityCard(
                driverContext: driverContext,
                avatarUrl: avatarUrl,
                onAvatarTap: () => _openAvatarSheet(
                  context,
                  driverContext: driverContext,
                  avatarUrl: avatarUrl,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            NokiSurfaceCard(
              key: const Key('profile-settings-card'),
              child: _PreferencesCard(
                locale: locale,
                themeMode: themeMode,
                onLocaleSelected: (selection) => ref
                    .read(localeProvider.notifier)
                    .setLocale(selection.first),
                onThemeSelected: (selection) => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(selection.first),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (profile != null) ...[
              _OperationalStatusCard(profile: profile),
              const SizedBox(height: AppSpacing.xl),
              _OrganizationCard(profile: profile),
              const SizedBox(height: AppSpacing.xl),
              _VehicleSummaryCard(profile: profile, scope: scope),
              const SizedBox(height: AppSpacing.xl),
              _ActivationCard(profile: profile),
              const SizedBox(height: AppSpacing.xl),
              _OperationalActivityCard(scope: scope),
              const SizedBox(height: AppSpacing.xl),
            ],
            NokiSurfaceCard(
              tone: NokiSurfaceTone.defaultTone,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('profile-logout-button'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.nokiColors.danger,
                    side: BorderSide(
                      color: context.nokiColors.danger.withValues(alpha: 0.55),
                    ),
                    minimumSize: const Size.fromHeight(
                      AppControlSize.minTouchTarget,
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.settingsLogout),
                  onPressed: () => _confirmLogout(context, ref),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAvatarSheet(
    BuildContext context, {
    required DriverContextResponseDto driverContext,
    required String? avatarUrl,
  }) async {
    final trimmedName = driverContext.displayName.trim();
    final initial = trimmedName.isEmpty ? 'N' : trimmedName[0].toUpperCase();
    final feedback = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          DriverAvatarSheet(initial: initial, currentAvatarUrl: avatarUrl),
    );
    if (feedback != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(feedback)),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsLogoutConfirmTitle),
        content: Text(l10n.settingsLogoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.settingsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.nokiColors.danger,
            ),
            child: Text(l10n.settingsLogout),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}

class _DriverIdentityCard extends StatelessWidget {
  const _DriverIdentityCard({
    required this.driverContext,
    required this.avatarUrl,
    required this.onAvatarTap,
  });

  final DriverContextResponseDto driverContext;
  final String? avatarUrl;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final trimmedName = driverContext.displayName.trim();
    final initial = trimmedName.isEmpty ? 'N' : trimmedName[0].toUpperCase();
    final authorizedServices = _authorizedServiceLabels(l10n, driverContext);
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return NokiSurfaceCard(
      key: const Key('profile-identity-card'),
      tone: NokiSurfaceTone.defaultTone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                button: true,
                label: l10n.profileAvatarEditTooltip,
                child: Tooltip(
                  message: l10n.profileAvatarEditTooltip,
                  child: InkWell(
                    key: const Key('profile-avatar-button'),
                    onTap: onAvatarTap,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: hasAvatar
                                ? Image.network(
                                    avatarUrl!,
                                    key: const Key('profile-avatar-image'),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => _AvatarInitials(
                                      initial: initial,
                                      colors: colors,
                                    ),
                                  )
                                : _AvatarInitials(
                                    initial: initial,
                                    colors: colors,
                                  ),
                          ),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.border),
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 13,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverContext.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      driverContext.email ?? l10n.profileNoEmail,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.profileAuthorizedServicesLabel,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            key: const Key('profile-authorized-services-wrap'),
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (authorizedServices.isEmpty)
                NokiBadge(
                  label: l10n.homeNoServices,
                  tone: NokiBadgeTone.neutral,
                )
              else
                for (final serviceLabel in authorizedServices)
                  NokiBadge(
                    label: serviceLabel,
                    tone: NokiBadgeTone.primary,
                    icon: Icons.check_circle_outline,
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.initial, required this.colors});

  final String initial;
  final NokiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.actionPrimary,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: colors.actionPrimaryInk,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

List<String> _authorizedServiceLabels(
  AppLocalizations l10n,
  DriverContextResponseDto driverContext,
) {
  final seen = <String>{};
  final labels = <String>[];
  void addLabel(String label) {
    if (seen.add(label)) labels.add(label);
  }

  for (final profile in driverContext.profiles) {
    if (profile.deliveryStatus != null) {
      addLabel(l10n.workFeedTypeDelivery);
    }
    for (final type in profile.serviceTypes) {
      switch (type) {
        case DriverContextProfileDtoServiceTypes.taxi:
          addLabel(l10n.serviceTypeTaxi);
        case DriverContextProfileDtoServiceTypes.taxiMoto:
          addLabel(l10n.serviceTypeTaxiMoto);
        case DriverContextProfileDtoServiceTypes.courier:
          addLabel(l10n.serviceTypeCourier);
        case DriverContextProfileDtoServiceTypes.cargo:
          addLabel(l10n.serviceTypeCargo);
        case DriverContextProfileDtoServiceTypes.unknown:
          break;
      }
    }
  }
  return labels;
}

class _OperationalStatusCard extends StatelessWidget {
  const _OperationalStatusCard({required this.profile});

  final DriverContextProfileDto profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final badges = <Widget>[
      _StatusPill(
        label: l10n.profileStatusDelivery,
        value: _deliveryStatusLabel(l10n, profile.deliveryStatus),
        tone: _deliveryStatusTone(profile.deliveryStatus),
      ),
    ];
    if (profile.mobilityOperationalStatus != null) {
      badges.add(
        _StatusPill(
          label: l10n.profileStatusMobility,
          value: _mobilityOperationalLabel(
            l10n,
            profile.mobilityOperationalStatus!,
          ),
          tone: _mobilityOperationalTone(profile.mobilityOperationalStatus!),
        ),
      );
    }
    if (profile.mobilityAvailabilityStatus != null) {
      badges.add(
        _StatusPill(
          label: l10n.profileStatusAvailability,
          value: _mobilityAvailabilityLabel(
            l10n,
            profile.mobilityAvailabilityStatus!,
          ),
          tone: _mobilityAvailabilityTone(profile.mobilityAvailabilityStatus!),
        ),
      );
    }

    return NokiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NokiSectionHeader(
            title: l10n.profileOperationalTitle,
            subtitle: l10n.homeCapabilitiesLabel,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: badges,
          ),
        ],
      ),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  const _OrganizationCard({required this.profile});

  final DriverContextProfileDto profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NokiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NokiSectionHeader(title: l10n.profileOrganizationTitle),
          const SizedBox(height: AppSpacing.lg),
          _InfoRow(
            label: l10n.profileOrganizationLabel,
            value: profile.organizationName,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: l10n.homeCountryLabel, value: profile.countryCode),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            label: l10n.homeCapabilitiesLabel,
            value: _serviceCapabilitiesLabel(l10n, profile),
          ),
        ],
      ),
    );
  }
}

class _VehicleSummaryCard extends StatelessWidget {
  const _VehicleSummaryCard({required this.profile, required this.scope});

  final DriverContextProfileDto profile;
  final DriverScope? scope;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vehicle = profile.assignedVehicle;
    return NokiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NokiSectionHeader(
            title: l10n.profileVehicleTitle,
            subtitle: _serviceCapabilitiesLabel(l10n, profile),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (vehicle == null)
            Text(l10n.profileVehicleUnavailable)
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  vehicle.type == DriverContextVehicleSummaryDtoType.motorcycle
                      ? Icons.moped_outlined
                      : Icons.directions_car_outlined,
                  color: context.nokiColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${l10n.vehiclePlateLabel}: ${vehicle.plate}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                NokiBadge(
                  label: _vehicleStatusLabel(l10n, vehicle.status),
                  tone: _vehicleStatusTone(vehicle.status),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                NokiBadge(
                  label:
                      vehicle.type ==
                          DriverContextVehicleSummaryDtoType.motorcycle
                      ? l10n.vehicleTypeMotorcycle
                      : l10n.vehicleTypeCar,
                  tone: NokiBadgeTone.neutral,
                ),
                for (final service in vehicle.allowedServiceTypes)
                  NokiBadge(
                    label: _vehicleServiceLabel(l10n, service),
                    tone: NokiBadgeTone.info,
                  ),
              ],
            ),
          ],
          if (scope != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VehiclesScreen(scope: scope!),
                  ),
                ),
                icon: const Icon(Icons.directions_car_outlined),
                label: Text(l10n.profileOpenVehicles),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivationCard extends StatelessWidget {
  const _ActivationCard({required this.profile});

  final DriverContextProfileDto profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NokiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NokiSectionHeader(title: l10n.profileActivationTitle),
          const SizedBox(height: AppSpacing.lg),
          if (profile.mobilityOnboardingStatus != null) ...[
            _InfoRow(
              label: l10n.profileStatusOnboarding,
              value: _mobilityOnboardingLabel(
                l10n,
                profile.mobilityOnboardingStatus!,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          NokiOperationalBanner(
            icon: Icons.badge_outlined,
            message: l10n.profileDocumentsBackendRequired,
            tone: NokiBadgeTone.info,
          ),
        ],
      ),
    );
  }
}

class _OperationalActivityCard extends StatelessWidget {
  const _OperationalActivityCard({required this.scope});

  final DriverScope? scope;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NokiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NokiSectionHeader(
            title: l10n.profileActivityTitle,
            subtitle: l10n.profileActivityBody,
          ),
          const SizedBox(height: AppSpacing.lg),
          NokiOperationalBanner(
            icon: Icons.notifications_none_outlined,
            message: l10n.profileNotificationsBackendRequired,
            tone: NokiBadgeTone.warning,
          ),
          if (scope != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DeliveryHistoryScreen(scope: scope!),
                      ),
                    ),
                    icon: const Icon(Icons.history),
                    label: Text(l10n.profileOpenHistory),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MobilityHistoryScreen(scope: scope!),
                      ),
                    ),
                    icon: const Icon(Icons.route_outlined),
                    label: Text(l10n.profileOpenMobilityHistory),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({
    required this.locale,
    required this.themeMode,
    required this.onLocaleSelected,
    required this.onThemeSelected,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final void Function(Set<Locale>) onLocaleSelected;
  final void Function(Set<ThemeMode>) onThemeSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NokiSectionHeader(title: l10n.profileSettingsSectionTitle),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.profileAppearanceLabel,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<ThemeMode>(
          key: const Key('profile-appearance-selector'),
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text(l10n.settingsThemeSystem),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text(l10n.settingsThemeLight),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text(l10n.settingsThemeDark),
            ),
          ],
          selected: {themeMode},
          onSelectionChanged: onThemeSelected,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.settingsLanguage,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<Locale>(
          key: const Key('profile-language-selector'),
          segments: const [
            ButtonSegment(value: Locale('fr'), label: Text('Français')),
            ButtonSegment(value: Locale('en'), label: Text('English')),
            ButtonSegment(value: Locale('ar'), label: Text('العربية')),
          ],
          selected: {locale},
          onSelectionChanged: onLocaleSelected,
        ),
      ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final NokiBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    return NokiBadge(label: '$label: $value', tone: tone);
  }
}

String _serviceCapabilitiesLabel(
  AppLocalizations l10n,
  DriverContextProfileDto profile,
) {
  final labels = <String>[];
  if (profile.deliveryStatus != null) labels.add(l10n.workFeedTypeDelivery);
  for (final type in profile.serviceTypes) {
    switch (type) {
      case DriverContextProfileDtoServiceTypes.taxi:
        labels.add(l10n.serviceTypeTaxi);
      case DriverContextProfileDtoServiceTypes.taxiMoto:
        labels.add(l10n.serviceTypeTaxiMoto);
      case DriverContextProfileDtoServiceTypes.courier:
        labels.add(l10n.serviceTypeCourier);
      case DriverContextProfileDtoServiceTypes.cargo:
        labels.add(l10n.serviceTypeCargo);
      case DriverContextProfileDtoServiceTypes.unknown:
        break;
    }
  }
  return labels.isEmpty ? l10n.homeNoServices : labels.join(' · ');
}

String _deliveryStatusLabel(
  AppLocalizations l10n,
  DriverContextProfileDtoDeliveryStatus? status,
) {
  return switch (status) {
    DriverContextProfileDtoDeliveryStatus.active => l10n.profileStatusActive,
    DriverContextProfileDtoDeliveryStatus.inactive =>
      l10n.profileStatusInactive,
    DriverContextProfileDtoDeliveryStatus.suspended =>
      l10n.profileStatusSuspended,
    null => l10n.profileStatusNotEnabled,
    DriverContextProfileDtoDeliveryStatus.unknown =>
      l10n.profileStatusUnavailable,
  };
}

NokiBadgeTone _deliveryStatusTone(
  DriverContextProfileDtoDeliveryStatus? status,
) {
  return switch (status) {
    DriverContextProfileDtoDeliveryStatus.active => NokiBadgeTone.success,
    DriverContextProfileDtoDeliveryStatus.inactive => NokiBadgeTone.offline,
    DriverContextProfileDtoDeliveryStatus.suspended => NokiBadgeTone.danger,
    null => NokiBadgeTone.neutral,
    DriverContextProfileDtoDeliveryStatus.unknown => NokiBadgeTone.neutral,
  };
}

String _mobilityOperationalLabel(
  AppLocalizations l10n,
  DriverContextProfileDtoMobilityOperationalStatus status,
) {
  return switch (status) {
    DriverContextProfileDtoMobilityOperationalStatus.active =>
      l10n.profileStatusActive,
    DriverContextProfileDtoMobilityOperationalStatus.inactive =>
      l10n.profileStatusInactive,
    DriverContextProfileDtoMobilityOperationalStatus.suspended =>
      l10n.profileStatusSuspended,
    DriverContextProfileDtoMobilityOperationalStatus.unknown =>
      l10n.profileStatusUnavailable,
  };
}

NokiBadgeTone _mobilityOperationalTone(
  DriverContextProfileDtoMobilityOperationalStatus status,
) {
  return switch (status) {
    DriverContextProfileDtoMobilityOperationalStatus.active =>
      NokiBadgeTone.success,
    DriverContextProfileDtoMobilityOperationalStatus.inactive =>
      NokiBadgeTone.offline,
    DriverContextProfileDtoMobilityOperationalStatus.suspended =>
      NokiBadgeTone.danger,
    DriverContextProfileDtoMobilityOperationalStatus.unknown =>
      NokiBadgeTone.neutral,
  };
}

String _mobilityAvailabilityLabel(
  AppLocalizations l10n,
  DriverContextProfileDtoMobilityAvailabilityStatus status,
) {
  return switch (status) {
    DriverContextProfileDtoMobilityAvailabilityStatus.offline =>
      l10n.profileStatusOffline,
    DriverContextProfileDtoMobilityAvailabilityStatus.available =>
      l10n.profileStatusAvailable,
    DriverContextProfileDtoMobilityAvailabilityStatus.busy =>
      l10n.profileStatusBusy,
    DriverContextProfileDtoMobilityAvailabilityStatus.unknown =>
      l10n.profileStatusUnavailable,
  };
}

// Mandatory NOKI convention (mission mandate §8): AVAILABLE is always green,
// BUSY is always red, OFFLINE is neutral grey - same rule applied to the
// mobility summary badge on Home (see availability_card.dart's
// `_summaryTone`), kept consistent here on Profile.
NokiBadgeTone _mobilityAvailabilityTone(
  DriverContextProfileDtoMobilityAvailabilityStatus status,
) {
  return switch (status) {
    DriverContextProfileDtoMobilityAvailabilityStatus.offline =>
      NokiBadgeTone.offline,
    DriverContextProfileDtoMobilityAvailabilityStatus.available =>
      NokiBadgeTone.success,
    DriverContextProfileDtoMobilityAvailabilityStatus.busy =>
      NokiBadgeTone.danger,
    DriverContextProfileDtoMobilityAvailabilityStatus.unknown =>
      NokiBadgeTone.neutral,
  };
}

String _mobilityOnboardingLabel(
  AppLocalizations l10n,
  DriverContextProfileDtoMobilityOnboardingStatus status,
) {
  return switch (status) {
    DriverContextProfileDtoMobilityOnboardingStatus.draft =>
      l10n.profileStatusDraft,
    DriverContextProfileDtoMobilityOnboardingStatus.submitted =>
      l10n.profileStatusSubmitted,
    DriverContextProfileDtoMobilityOnboardingStatus.underReview =>
      l10n.profileStatusUnderReview,
    DriverContextProfileDtoMobilityOnboardingStatus.approved =>
      l10n.profileStatusApproved,
    DriverContextProfileDtoMobilityOnboardingStatus.rejected =>
      l10n.profileStatusRejected,
    DriverContextProfileDtoMobilityOnboardingStatus.suspended =>
      l10n.profileStatusSuspended,
    DriverContextProfileDtoMobilityOnboardingStatus.unknown =>
      l10n.profileStatusUnavailable,
  };
}

String _vehicleStatusLabel(
  AppLocalizations l10n,
  DriverContextVehicleSummaryDtoStatus status,
) {
  return switch (status) {
    DriverContextVehicleSummaryDtoStatus.active => l10n.vehicleStatusActive,
    DriverContextVehicleSummaryDtoStatus.pendingValidation =>
      l10n.vehicleStatusPendingValidation,
    DriverContextVehicleSummaryDtoStatus.suspended =>
      l10n.vehicleStatusSuspended,
    DriverContextVehicleSummaryDtoStatus.retired => l10n.vehicleStatusRetired,
    DriverContextVehicleSummaryDtoStatus.unknown =>
      l10n.profileStatusUnavailable,
  };
}

NokiBadgeTone _vehicleStatusTone(DriverContextVehicleSummaryDtoStatus status) {
  return switch (status) {
    DriverContextVehicleSummaryDtoStatus.active => NokiBadgeTone.success,
    DriverContextVehicleSummaryDtoStatus.pendingValidation =>
      NokiBadgeTone.warning,
    DriverContextVehicleSummaryDtoStatus.suspended => NokiBadgeTone.danger,
    DriverContextVehicleSummaryDtoStatus.retired => NokiBadgeTone.neutral,
    DriverContextVehicleSummaryDtoStatus.unknown => NokiBadgeTone.neutral,
  };
}

String _vehicleServiceLabel(
  AppLocalizations l10n,
  DriverContextVehicleSummaryDtoAllowedServiceTypes service,
) {
  return switch (service) {
    DriverContextVehicleSummaryDtoAllowedServiceTypes.taxi =>
      l10n.serviceTypeTaxi,
    DriverContextVehicleSummaryDtoAllowedServiceTypes.taxiMoto =>
      l10n.serviceTypeTaxiMoto,
    DriverContextVehicleSummaryDtoAllowedServiceTypes.courier =>
      l10n.serviceTypeCourier,
    DriverContextVehicleSummaryDtoAllowedServiceTypes.cargo =>
      l10n.serviceTypeCargo,
    DriverContextVehicleSummaryDtoAllowedServiceTypes.unknown =>
      l10n.profileStatusUnavailable,
  };
}
