import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'auth_providers.dart';

/// Shown when the authenticated actor has no Driver profile anywhere
/// (DRIVER-APP-01 section 15 role guard). A valid JWT is not enough to use
/// this app - an ADMIN or SELLER account lands here, not on the home shell.
class AccessDeniedScreen extends ConsumerWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block_outlined, size: 40, color: colors.danger),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.accessDeniedTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.accessDeniedBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  OutlinedButton(
                    onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                    child: Text(l10n.accessDeniedSignOut),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
