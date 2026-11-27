import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/profile/driver_avatar_models.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_localizer.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/noki_ui.dart';
import '../auth/auth_providers.dart';
import 'driver_avatar_picker.dart';

class DriverAvatarSheet extends ConsumerStatefulWidget {
  const DriverAvatarSheet({
    super.key,
    required this.initial,
    required this.currentAvatarUrl,
  });

  final String initial;
  final String? currentAvatarUrl;

  @override
  ConsumerState<DriverAvatarSheet> createState() => _DriverAvatarSheetState();
}

class _DriverAvatarSheetState extends ConsumerState<DriverAvatarSheet> {
  PickedAvatarImage? _pendingImage;
  bool _busy = false;
  String? _errorMessage;

  Future<void> _pick(DriverAvatarSource source) async {
    if (_busy) return;
    setState(() => _errorMessage = null);
    final picked = await ref.read(driverAvatarPickerProvider).pick(source);
    if (picked != null && mounted) {
      setState(() => _pendingImage = picked);
    }
  }

  Future<void> _savePending() async {
    final pending = _pendingImage;
    if (_busy || pending == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      final api = ref.read(driverApiClientProvider);
      final intent = await api.createDriverAvatarUploadIntent(
        contentType: pending.contentType,
        byteSizeExpected: pending.bytes.length,
      );
      await api.uploadDriverAvatarBytes(
        uploadUrl: intent.uploadUrl,
        headers: intent.uploadHeaders,
        bytes: pending.bytes,
      );
      final completed = await api.completeDriverAvatarUpload(intent.intentId);
      ref
          .read(authControllerProvider.notifier)
          .updateAvatarUrl(completed.avatarUrl);
      if (mounted) {
        Navigator.of(context).pop(l10n.profileAvatarSavedMessage);
      }
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _errorMessage =
            (failure.type == AppFailureType.notFound ||
                failure.type == AppFailureType.forbidden)
            ? l10n.profileAvatarUnavailableMessage
            : localizeFailure(context, failure);
      });
    }
  }

  Future<void> _removeAvatar() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      await ref.read(driverApiClientProvider).removeDriverAvatar();
      ref.read(authControllerProvider.notifier).updateAvatarUrl(null);
      if (mounted) {
        Navigator.of(context).pop(l10n.profileAvatarRemovedMessage);
      }
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _errorMessage =
            (failure.type == AppFailureType.notFound ||
                failure.type == AppFailureType.forbidden)
            ? l10n.profileAvatarUnavailableMessage
            : localizeFailure(context, failure);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final hasCurrent =
        widget.currentAvatarUrl != null && widget.currentAvatarUrl!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.profileAvatarSheetTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: SizedBox(
                  key: const Key('avatar-preview-box'),
                  width: 112,
                  height: 112,
                  child: _pendingImage != null
                      ? Image.memory(
                          _pendingImage!.bytes,
                          key: const Key('avatar-preview-memory-image'),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _InitialFallback(initial: widget.initial),
                        )
                      : hasCurrent
                      ? Image.network(
                          widget.currentAvatarUrl!,
                          key: const Key('avatar-preview-network-image'),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _InitialFallback(initial: widget.initial),
                        )
                      : _InitialFallback(initial: widget.initial),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              NokiOperationalBanner(
                icon: Icons.error_outline,
                message: _errorMessage!,
                tone: NokiBadgeTone.danger,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (_pendingImage != null) ...[
              FilledButton.icon(
                key: const Key('avatar-save-button'),
                onPressed: _busy ? null : _savePending,
                icon: _busy
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.actionPrimaryInk,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(l10n.profileAvatarSave),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            OutlinedButton.icon(
              key: const Key('avatar-pick-gallery-button'),
              onPressed: _busy ? null : () => _pick(DriverAvatarSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                hasCurrent && _pendingImage == null
                    ? l10n.profileAvatarReplace
                    : l10n.profileAvatarChooseGallery,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              key: const Key('avatar-pick-camera-button'),
              onPressed: _busy ? null : () => _pick(DriverAvatarSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l10n.profileAvatarChooseCamera),
            ),
            if (hasCurrent) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                key: const Key('avatar-remove-button'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.danger,
                  side: BorderSide(color: colors.danger.withValues(alpha: 0.5)),
                ),
                onPressed: _busy ? null : _removeAvatar,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.profileAvatarRemove),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.settingsCancel),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialFallback extends StatelessWidget {
  const _InitialFallback({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    return Container(
      color: colors.actionPrimary,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          color: colors.actionPrimaryInk,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
