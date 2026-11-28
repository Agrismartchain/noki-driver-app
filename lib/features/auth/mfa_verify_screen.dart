import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failure_localizer.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/noki_ui.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

/// Shown when a password-only login response comes back with
/// `mfaStatus: 'VERIFY'` - the account already has an active authenticator
/// and must prove it before a session is issued (see
/// `AuthController.verifyMfa`). Offers a fallback to a one-time recovery
/// code for a driver who has lost access to their authenticator app.
class MfaVerifyScreen extends ConsumerStatefulWidget {
  const MfaVerifyScreen({super.key});

  @override
  ConsumerState<MfaVerifyScreen> createState() => _MfaVerifyScreenState();
}

class _MfaVerifyScreenState extends ConsumerState<MfaVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _recoveryCodeController = TextEditingController();
  bool _useRecoveryCode = false;

  @override
  void dispose() {
    _codeController.dispose();
    _recoveryCodeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(authControllerProvider.notifier);
    if (_useRecoveryCode) {
      notifier.verifyMfa(recoveryCode: _recoveryCodeController.text.trim());
    } else {
      notifier.verifyMfa(code: _codeController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final isSubmitting = authState.status == AuthStatus.authenticating;
    final colors = context.nokiColors;

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
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                l10n.mfaVerifyHeadline,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(color: colors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _useRecoveryCode
                                  ? l10n.mfaVerifyRecoveryCodeRequired
                                  : l10n.mfaVerifyInstructions,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colors.textSecondary),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            if (_useRecoveryCode)
                              TextFormField(
                                key: const ValueKey('recoveryCodeField'),
                                controller: _recoveryCodeController,
                                textInputAction: TextInputAction.done,
                                enabled: !isSubmitting,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: colors.textPrimary),
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: l10n.mfaVerifyRecoveryCodeLabel,
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? l10n.mfaVerifyRecoveryCodeRequired
                                    : null,
                              )
                            else
                              TextFormField(
                                key: const ValueKey('codeField'),
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.oneTimeCode,
                                ],
                                enabled: !isSubmitting,
                                maxLength: 6,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: colors.textPrimary,
                                      letterSpacing: 3,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: l10n.mfaVerifyCodeLabel,
                                  counterText: '',
                                ),
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) {
                                    return l10n.mfaVerifyCodeRequired;
                                  }
                                  if (!RegExp(r'^\d{6}$').hasMatch(v)) {
                                    return l10n.mfaVerifyCodeRequired;
                                  }
                                  return null;
                                },
                              ),
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => setState(() {
                                        _useRecoveryCode = !_useRecoveryCode;
                                        _formKey.currentState?.reset();
                                      }),
                                child: Text(
                                  _useRecoveryCode
                                      ? l10n.mfaVerifyUseAuthenticatorCode
                                      : l10n.mfaVerifyUseRecoveryCode,
                                ),
                              ),
                            ),
                            if (authState.failure != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                localizeFailure(context, authState.failure!),
                                style: Theme.of(context).textTheme.bodyMedium
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
                                  : Text(l10n.mfaVerifySubmit),
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
