import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'noki_ui.dart';

enum NokiFinanceTone { earnings, cod, collect, remit }

String formatNokiMoney(
  String amount, {
  String? currencyCode,
  bool preferFcfa = false,
}) {
  final normalizedCode = (currencyCode ?? '').trim().toUpperCase();
  final displayCode = switch (normalizedCode) {
    'XOF' || 'FCFA' => 'FCFA',
    '' when preferFcfa => 'FCFA',
    '' => null,
    _ => currencyCode,
  };
  return displayCode == null ? amount : '$amount $displayCode';
}

class NokiFinanceCallout extends StatelessWidget {
  const NokiFinanceCallout({
    super.key,
    required this.label,
    required this.amount,
    this.currencyCode,
    this.caption,
    this.icon,
    this.trailing,
    this.tone = NokiFinanceTone.earnings,
    this.preferFcfa = false,
  });

  final String label;
  final String amount;
  final String? currencyCode;
  final String? caption;
  final IconData? icon;
  final Widget? trailing;
  final NokiFinanceTone tone;
  final bool preferFcfa;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final metrics = context.nokiMetrics;
    final scheme = switch (tone) {
      NokiFinanceTone.earnings => (
        colors.surfaceElevated,
        colors.border,
        colors.textPrimary,
        colors.financePositive,
        false,
      ),
      NokiFinanceTone.cod => (
        colors.codSurface,
        colors.codAccent,
        colors.codAccentInk,
        colors.textPrimary,
        true,
      ),
      NokiFinanceTone.collect => (
        colors.codSurface,
        colors.codAccent,
        colors.codAccentInk,
        colors.textPrimary,
        true,
      ),
      NokiFinanceTone.remit => (
        colors.dangerSurface,
        colors.danger,
        colors.danger,
        colors.danger,
        false,
      ),
    };

    final content = Container(
      decoration: BoxDecoration(
        color: scheme.$1,
        borderRadius: BorderRadius.circular(metrics.radiusCard),
        border: Border.all(
          color: scheme.$5 ? Colors.transparent : scheme.$2,
          width: scheme.$5 ? 0 : metrics.borderWidthEmphasis,
        ),
      ),
      padding: EdgeInsets.all(metrics.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: metrics.iconMedium, color: scheme.$3),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.$3,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            formatNokiMoney(
              amount,
              currencyCode: currencyCode,
              preferFcfa: preferFcfa,
            ),
            style: Theme.of(context).textTheme.displaySmall
                ?.copyWith(color: scheme.$4, fontWeight: FontWeight.w800),
          ),
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              caption!,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: scheme.$3),
            ),
          ],
        ],
      ),
    );

    if (!scheme.$5) return content;
    return CustomPaint(
      painter: _DashedRoundedRectPainter(
        color: scheme.$2,
        radius: metrics.radiusCard,
      ),
      child: content,
    );
  }
}

class NokiFinanceNotice extends StatelessWidget {
  const NokiFinanceNotice({
    super.key,
    required this.message,
    this.tone = NokiBadgeTone.warning,
  });

  final String message;
  final NokiBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    return NokiOperationalBanner(
      icon: tone == NokiBadgeTone.danger
          ? Icons.warning_amber_rounded
          : Icons.info_outline,
      message: message,
      tone: tone,
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  const _DashedRoundedRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect.deflate(0.75), Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      const dash = 8.0;
      const gap = 6.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          math.min(distance + dash, metric.length),
        );
        canvas.drawPath(segment, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
