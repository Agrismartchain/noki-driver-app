import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failure_localizer.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/noki_ui.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

/// Shown once, right after a password-only login response comes back with
/// `mfaStatus: 'ENROLL'` - the account must set up an authenticator before a
/// session can exist (see `AuthController.startMfaEnrollment`/
/// `confirmMfaEnrollment`). Fetches the one-time setup secret itself on
/// first build so the driver never has to tap an extra button to see it.
class MfaEnrollScreen extends ConsumerStatefulWidget {
  const MfaEnrollScreen({super.key});

  @override
  ConsumerState<MfaEnrollScreen> createState() => _MfaEnrollScreenState();
}

class _MfaEnrollScreenState extends ConsumerState<MfaEnrollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _requestedEnrollmentStart = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(authControllerProvider.notifier)
        .confirmMfaEnrollment(code: _codeController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final colors = context.nokiColors;
    final enrollment = authState.mfaChallenge?.enrollment;
    final isSubmitting = authState.status == AuthStatus.authenticating;

    // Kicks off exactly once per screen instance - `startMfaEnrollment` is
    // itself idempotent (see its doc comment) but there is no reason to
    // call it again on every rebuild.
    if (enrollment == null && !_requestedEnrollmentStart) {
      _requestedEnrollmentStart = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authControllerProvider.notifier).startMfaEnrollment();
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: NokiScreenBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                AppSpacing.xxl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - AppSpacing.xxxl).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: NokiSurfaceCard(
                      tone: NokiSurfaceTone.defaultTone,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: enrollment == null
                          ? _LoadingBody(
                              message: l10n.mfaEnrollLoadingSecret,
                              colors: colors,
                            )
                          : Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      l10n.mfaEnrollHeadline,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(color: colors.textPrimary),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    l10n.mfaEnrollInstructions,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: colors.textSecondary),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  Text(
                                    l10n.mfaEnrollSecretLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(color: colors.textSecondary),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Container(
                                    key: const Key('mfa-enroll-secret-box'),
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                      AppSpacing.md,
                                      AppSpacing.sm,
                                      AppSpacing.xs,
                                      AppSpacing.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceSubtle,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.md,
                                      ),
                                      border: Border.all(
                                        color: colors.borderStrong,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: SelectableText(
                                            enrollment.secretBase32,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: colors.textPrimary,
                                                  letterSpacing: 1.1,
                                                  fontFeatures: const [
                                                    FontFeature.tabularFigures(),
                                                  ],
                                                ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.copy_outlined),
                                          tooltip: l10n.mfaEnrollCopySecret,
                                          color: colors.textPrimary,
                                          onPressed: () async {
                                            await Clipboard.setData(
                                              ClipboardData(
                                                text: enrollment.secretBase32,
                                              ),
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    l10n.mfaEnrollSecretCopied,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  TextFormField(
                                    controller: _codeController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.oneTimeCode,
                                    ],
                                    enabled: !isSubmitting,
                                    maxLength: 6,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: colors.textPrimary,
                                          letterSpacing: 3,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                    onFieldSubmitted: (_) => _submit(),
                                    decoration: InputDecoration(
                                      labelText: l10n.mfaEnrollCodeLabel,
                                      counterText: '',
                                    ),
                                    validator: (value) {
                                      final v = value?.trim() ?? '';
                                      if (v.isEmpty) {
                                        return l10n.mfaEnrollCodeRequired;
                                      }
                                      if (!RegExp(r'^\d{6}$').hasMatch(v)) {
                                        return l10n.mfaEnrollCodeInvalidFormat;
                                      }
                                      return null;
                                    },
                                  ),
                                  if (authState.failure != null) ...[
                                    const SizedBox(height: AppSpacing.lg),
                                    Text(
                                      localizeFailure(
                                        context,
                                        authState.failure!,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: colors.danger),
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.xl),
                                  ElevatedButton(
                                    onPressed: isSubmitting ? null : _submit,
                                    child: isSubmitting
                                        ? SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: colors.actionPrimaryInk,
                                            ),
                                          )
                                        : Text(l10n.mfaEnrollSubmit),
                                  ),
                                ],
                              ),
                            ),
                    ),
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

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.message, required this.colors});

  final String message;
  final NokiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          CircularProgressIndicator(color: colors.actionPrimary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
