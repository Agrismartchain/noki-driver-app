import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/generated/app_localizations.dart';
import '../../core/i18n/locale_controller.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../auth/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider) ?? defaultLocale;
    final themeMode = ref.watch(themeModeProvider);
    final colors = context.nokiColors;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.settingsLanguage, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<Locale>(
            segments: const [
              ButtonSegment(value: Locale('fr'), label: Text('Français')),
              ButtonSegment(value: Locale('en'), label: Text('English')),
              ButtonSegment(value: Locale('ar'), label: Text('العربية')),
            ],
            selected: {locale},
            onSelectionChanged: (selection) => ref.read(localeProvider.notifier).setLocale(selection.first),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.settingsTheme, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(l10n.settingsThemeSystem)),
              ButtonSegment(value: ThemeMode.light, label: Text(l10n.settingsThemeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(l10n.settingsThemeDark)),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) => ref.read(themeModeProvider.notifier).setThemeMode(selection.first),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          // Deliberately neutral, not primary-yellow or destructive-red:
          // signing out is a real but non-critical, non-destructive action
          // and must not visually compete with primary CTAs or the selected
          // availability state (both use the NOKI accent yellow). See
          // DRIVER-APP-01R V-2.
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textSecondary,
              side: BorderSide(color: colors.border),
            ),
            icon: const Icon(Icons.logout),
            label: Text(l10n.settingsLogout),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsLogoutConfirmTitle),
        content: Text(l10n.settingsLogoutConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.settingsCancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.settingsLogout)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}
