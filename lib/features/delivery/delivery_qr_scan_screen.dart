import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_localizer.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../driver_context/driver_context_repository.dart';
import 'delivery_mission_detail_screen.dart';
import 'delivery_qr_entry_screen.dart';
import 'delivery_repository.dart';

/// Real camera QR scanning (mandate DRIVER-APP-04 §17-19). Confirmed
/// contractually legitimate before writing this: `POST
/// /v1/delivery/shipments/:id/qr/issue` is a real, existing endpoint that
/// returns a genuine, driver-scannable token, and the scan endpoint
/// (`scanMissionQr`, already wired since DRIVER-APP-02) has no invented
/// behavior here - this screen only feeds a camera-decoded string into the
/// exact same call [DeliveryQrEntryScreen] already made from a text field.
///
/// Camera permission is requested by `mobile_scanner` only when this screen
/// starts the camera - never at app startup. Manual entry
/// ([DeliveryQrEntryScreen]) remains one tap away in both directions, and is
/// what a permission-denied/no-camera device falls back to automatically.
class DeliveryQrScanScreen extends ConsumerStatefulWidget {
  const DeliveryQrScanScreen({super.key, required this.scope});

  final DriverScope scope;

  @override
  ConsumerState<DeliveryQrScanScreen> createState() =>
      _DeliveryQrScanScreenState();
}

class _DeliveryQrScanScreenState extends ConsumerState<DeliveryQrScanScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _submitting = false;
  bool _handled = false;
  AppFailure? _failure;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_submitting || _handled) return;
    final raw = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    _handled = true;
    setState(() {
      _submitting = true;
      _failure = null;
    });
    try {
      final mission = await ref.read(deliveryRepositoryProvider).scanQr(raw);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DeliveryMissionDetailScreen(
            missionId: mission.id,
            scope: widget.scope,
          ),
        ),
      );
    } on AppFailure catch (failure) {
      // A rejected token (wrong mission, expired, wrong status) is not a
      // reason to lock the scanner - let the driver try another code.
      if (mounted) {
        setState(() {
          _failure = failure;
          _handled = false;
        });
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _openManualEntry() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DeliveryQrEntryScreen(scope: widget.scope),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qrScanTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_outlined),
            tooltip: l10n.qrScanManualEntryCta,
            onPressed: _openManualEntry,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) =>
                _CameraErrorView(error: error, onManualEntry: _openManualEntry),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_submitting)
                          SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.actionPrimary,
                            ),
                          ),
                        if (_submitting) const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.qrScanHint,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    if (_failure != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        localizeFailure(context, _failure!),
                        style: TextStyle(color: colors.danger),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.error, required this.onManualEntry});

  final MobileScannerException error;
  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.nokiColors;
    final message = error.errorCode == MobileScannerErrorCode.permissionDenied
        ? l10n.qrScanPermissionDenied
        : l10n.qrScanCameraUnavailable;

    return ColoredBox(
      color: colors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam_off_outlined,
                size: 40,
                color: colors.textMuted,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: onManualEntry,
                child: Text(l10n.qrScanManualEntryCta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
