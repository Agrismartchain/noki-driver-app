import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

enum NokiBadgeTone {
  neutral,
  primary,
  success,
  warning,
  danger,
  info,
  offline,
  cod,
}

class NokiScreenBackground extends StatelessWidget {
  const NokiScreenBackground({
    super.key,
    required this.child,
    this.showMapGrid = false,
    this.safeTop = false,
    this.safeBottom = false,
  });

  final Widget child;
  final bool showMapGrid;
  final bool safeTop;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final metrics = context.nokiMetrics;
    final content = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.background, colors.background, colors.surfaceSubtle],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -72,
            right: -40,
            child: _GlowOrb(
              color: colors.actionPrimary.withValues(alpha: 0.18),
              size: 180,
            ),
          ),
          Positioned(
            top: 96,
            left: -54,
            child: _GlowOrb(
              color: colors.codAccent.withValues(alpha: 0.10),
              size: 144,
            ),
          ),
          if (showMapGrid)
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(
                  lineColor: colors.borderSubtle,
                  accentColor: colors.actionPrimary.withValues(alpha: 0.12),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.background.withValues(alpha: 0.12),
                    colors.background.withValues(alpha: 0.50),
                    colors.background.withValues(alpha: 0.92),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: safeTop ? metrics.safeAreaInset : 0,
              bottom: safeBottom ? metrics.safeAreaInset : 0,
            ),
            child: child,
          ),
        ],
      ),
    );

    if (!safeTop && !safeBottom) return content;
    return SafeArea(top: safeTop, bottom: safeBottom, child: content);
  }
}

class NokiSurfaceCard extends StatelessWidget {
  const NokiSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.tone = NokiSurfaceTone.defaultTone,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final NokiSurfaceTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final metrics = context.nokiMetrics;
    final surfaceColor = switch (tone) {
      NokiSurfaceTone.defaultTone => colors.surfaceElevated,
      NokiSurfaceTone.subtle => colors.surfaceSubtle,
      NokiSurfaceTone.selected => colors.surfaceSelected,
      NokiSurfaceTone.inverse => colors.chromeSurface,
      NokiSurfaceTone.cod => colors.codSurface,
    };
    final borderColor = tone == NokiSurfaceTone.cod
        ? colors.codAccent
        : colors.border;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(metrics.radiusCard),
        border: Border.all(
          color: borderColor,
          width: tone == NokiSurfaceTone.cod
              ? metrics.borderWidthEmphasis
              : metrics.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor.withValues(
              alpha: tone == NokiSurfaceTone.inverse ? 0.18 : 0.08,
            ),
            blurRadius: tone == NokiSurfaceTone.inverse ? 28 : 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(metrics.cardPadding),
        child: child,
      ),
    );

    final materialCard = Material(color: Colors.transparent, child: card);

    if (onTap == null) return materialCard;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(metrics.radiusCard),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

enum NokiSurfaceTone { defaultTone, subtle, selected, inverse, cod }

class NokiSectionHeader extends StatelessWidget {
  const NokiSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        ...?trailing == null ? null : [trailing!],
      ],
    );
  }
}

class NokiBadge extends StatelessWidget {
  const NokiBadge({
    super.key,
    required this.label,
    this.tone = NokiBadgeTone.neutral,
    this.icon,
  });

  final String label;
  final NokiBadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final metrics = context.nokiMetrics;
    final scheme = switch (tone) {
      NokiBadgeTone.primary => (colors.actionPrimary, colors.actionPrimaryInk),
      NokiBadgeTone.success => (colors.successSurface, colors.success),
      NokiBadgeTone.warning => (colors.warningSurface, colors.warning),
      NokiBadgeTone.danger => (colors.dangerSurface, colors.danger),
      NokiBadgeTone.info => (colors.infoSurface, colors.info),
      NokiBadgeTone.offline => (colors.chromeSurface, colors.textInverse),
      NokiBadgeTone.cod => (colors.codSurface, colors.codAccentInk),
      NokiBadgeTone.neutral => (colors.surfaceSubtle, colors.textSecondary),
    };

    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: metrics.badgeHorizontalPadding,
        vertical: metrics.badgeVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: scheme.$1,
        borderRadius: BorderRadius.circular(metrics.radiusPill),
        border: Border.all(
          color: tone == NokiBadgeTone.offline
              ? colors.chromeBorder
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...?icon == null
              ? null
              : [
                  Icon(icon, size: metrics.badgeIconSize, color: scheme.$2),
                  const SizedBox(width: AppSpacing.xs),
                ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: scheme.$2),
            ),
          ),
        ],
      ),
    );
  }
}

class NokiOperationalBanner extends StatelessWidget {
  const NokiOperationalBanner({
    super.key,
    required this.icon,
    required this.message,
    required this.tone,
    this.action,
  });

  final IconData icon;
  final String message;
  final NokiBadgeTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final metrics = context.nokiMetrics;
    final scheme = switch (tone) {
      NokiBadgeTone.warning => (colors.warningSurface, colors.warning),
      NokiBadgeTone.danger => (colors.dangerSurface, colors.danger),
      NokiBadgeTone.info => (colors.infoSurface, colors.info),
      NokiBadgeTone.offline => (colors.chromeSurface, colors.textInverse),
      _ => (colors.surfaceSubtle, colors.textPrimary),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(metrics.radiusCard),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(metrics.cardPadding),
          decoration: BoxDecoration(
            color: scheme.$1.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(metrics.radiusCard),
            border: Border.all(
              color: tone == NokiBadgeTone.offline
                  ? colors.chromeBorder
                  : scheme.$2.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: scheme.$2, size: metrics.iconMedium),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: scheme.$2),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: AppSpacing.md),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class NokiMetricPill extends StatelessWidget {
  const NokiMetricPill({
    super.key,
    required this.icon,
    required this.label,
    this.emphasis = false,
  });

  final IconData icon;
  final String label;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final metrics = context.nokiMetrics;

    return ClipRRect(
      borderRadius: BorderRadius.circular(metrics.radiusButton),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: emphasis
                ? colors.surfaceElevated.withValues(alpha: 0.94)
                : colors.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(metrics.radiusButton),
            border: Border.all(
              color: emphasis
                  ? colors.actionPrimary.withValues(alpha: 0.36)
                  : colors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: metrics.badgeIconSize,
                color: emphasis ? colors.actionPrimary : colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: emphasis ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.lineColor, required this.accentColor});

  final Color lineColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 28.0;
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 1.5;

    for (double x = 0; x < size.width; x += gap) {
      final paint = (x / gap).round().isEven ? linePaint : accentPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      final paint = (y / gap).round().isEven ? linePaint : accentPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.accentColor != accentColor;
  }
}
