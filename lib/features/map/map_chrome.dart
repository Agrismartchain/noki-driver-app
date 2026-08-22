import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

class NokiMapControlButton extends StatelessWidget {
  const NokiMapControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final metrics = context.nokiMetrics;

    return Tooltip(
      message: tooltip ?? '',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(metrics.radiusButton),
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: colors.surface.withValues(alpha: 0.92),
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                width: AppControlSize.minTouchTarget,
                height: AppControlSize.minTouchTarget,
                child: Icon(icon, color: colors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NokiMapStatusChip extends StatelessWidget {
  const NokiMapStatusChip({
    super.key,
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final bg = backgroundColor ?? colors.surface.withValues(alpha: 0.9);
    final fg = foregroundColor ?? colors.textPrimary;
    final maxChipWidth = MediaQuery.sizeOf(context).width - (AppSpacing.lg * 2);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxChipWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(icon, size: 16, color: fg),
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    label,
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NokiMapBottomPanel extends StatelessWidget {
  const NokiMapBottomPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final metrics = context.nokiMetrics;

    return ClipRRect(
      borderRadius: BorderRadius.circular(metrics.radiusCard + 4),
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(metrics.radiusCard + 4),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.shadowColor.withValues(alpha: 0.14),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          // Capped and internally scrollable (mandate: the top status strip -
          // service/GPS/route chips, which can grow to 2-3 wrapped rows once
          // ETA/distance/maneuver or a route-unavailable+retry pair join the
          // base chips - must never be painted over by this panel, which is
          // the last/topmost Stack child on both map screens). Without a cap
          // this panel sizes to its full (mission-dependent) content height
          // and, on shorter screens or content-heavy missions, can grow tall
          // enough to visually occlude those chips even though they remain
          // in the semantics tree (mandate §22: semantics present, pixels
          // absent). Uncapped Column + `mainAxisSize.min` still applies
          // within the cap, so short content keeps its natural height.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.borderStrong,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Flexible(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
