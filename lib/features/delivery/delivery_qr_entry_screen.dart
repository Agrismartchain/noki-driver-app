import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_localizer.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../driver_context/driver_context_repository.dart';
import 'delivery_mission_detail_screen.dart';
import 'delivery_repository.dart';

/// QR entry point required by mandate §21. The token
/// (`ScanDeliveryQrDto.token`, 32-256 chars) is opaque and not something a
/// human reads off a label - camera scanning is explicitly deferred to a
/// later phase (§23/§63). This screen is the interim, contractually-valid
/// path: manual paste, useful for QA and for a driver relaying a token given
/// to them out of band, submitted to the same endpoint a real scanner would
/// call.
class DeliveryQrEntryScreen extends ConsumerStatefulWidget {
  const DeliveryQrEntryScreen({super.key, required this.scope});

  final DriverScope scope;

  @override
  ConsumerState<DeliveryQrEntryScreen> createState() => _DeliveryQrEntryScreenState();
}

class _DeliveryQrEntryScreenState extends ConsumerState<DeliveryQrEntryScreen> {
  final _tokenController = TextEditingController();
  bool _submitting = false;
  AppFailure? _failure;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty || _submitting) return;
    setState(() {
      _submitting = true;
      _failure = null;
    });
    try {
      final mission = await ref.read(deliveryRepositoryProvider).scanQr(token);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DeliveryMissionDetailScreen(missionId: mission.id, scope: widget.scope)),
      );
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.qrEntryTitle)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.qrEntryHint, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textMuted)),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _tokenController,
              minLines: 2,
              maxLines: 4,
              enabled: !_submitting,
              decoration: InputDecoration(labelText: l10n.qrEntryTokenLabel),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.actionPrimaryInk))
                  : Text(l10n.qrEntrySubmitCta),
            ),
            if (_failure != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(localizeFailure(context, _failure!), style: TextStyle(color: colors.danger)),
            ],
          ],
        ),
      ),
    );
  }
}
