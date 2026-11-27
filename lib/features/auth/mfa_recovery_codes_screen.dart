import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/noki_ui.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

/// Shown exactly once, right after `confirmMfaEnrollment` succeeds - see
/// `AuthStatus.mfaRecoveryCodesPending`'s doc comment for why tokens are
/// deliberately not yet persisted and `/v1/driver/context` not yet called
/// when this screen is reached. The backend never shows these codes again,
/// so there is no "skip" action here - only acknowledging them moves on.
class MfaRecoveryCodesScreen extends ConsumerWidget {
  const MfaRecoveryCodesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final colors = context.nokiColors;
    final codes = authState.pendingRecoveryCodes?.recoveryCodes ?? const <String>[];
    final isSubmitting = authState.status == AuthStatus.authenticating;

    return Scaffold(
      body: NokiScreenBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: NokiSurfaceCard(
                  tone: NokiSurfaceTone.inverse,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.mfaRecoveryCodesHeadline,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: colors.textInverse),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.mfaRecoveryCodesWarning,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      NokiSurfaceCard(
                        tone: NokiSurfaceTone.subtle,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Wrap(
                          spacing: AppSpacing.lg,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final code in codes)
                              Text(
                                code,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colors.textInverse,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      OutlinedButton.icon(
                        onPressed: codes.isEmpty
                            ? null
                            : () async {
                                await Clipboard.setData(
                                  ClipboardData(text: codes.join('\n')),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.mfaRecoveryCodesCopied)),
                                  );
                                }
                              },
                        icon: const Icon(Icons.copy_outlined),
                        label: Text(l10n.mfaRecoveryCodesCopyAll),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () => ref
                                  .read(authControllerProvider.notifier)
                                  .acknowledgeRecoveryCodes(),
                        child: isSubmitting
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.actionPrimaryInk,
                                ),
                              )
                            : Text(l10n.mfaRecoveryCodesAcknowledge),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
