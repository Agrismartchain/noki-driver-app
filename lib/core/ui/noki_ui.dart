import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/motion.dart';

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

/// Sober full-screen container using the semantic NOKI background surface.
///
/// The legacy `showMapGrid` parameter is kept only for source compatibility
/// and intentionally renders no grid or textured glow orbs so operational
/// screens stay calm and legible in bright sunlight and dark mode.
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
    Widget content = Padding(
      padding: EdgeInsetsDirectional.only(
        top: safeTop ? metrics.safeAreaInset : 0,
        bottom: safeBottom ? metrics.safeAreaInset : 0,
      ),
      child: child,
    );

    if (safeTop || safeBottom) {
      content = SafeArea(top: safeTop, bottom: safeBottom, child: content);
    }

    return ColoredBox(color: colors.background, child: content);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = switch (tone) {
      NokiSurfaceTone.defaultTone => colors.surfaceElevated,
      NokiSurfaceTone.subtle => colors.surfaceSubtle,
      NokiSurfaceTone.selected => colors.surfaceSelected,
      NokiSurfaceTone.inverse => colors.chromeSurface,
      NokiSurfaceTone.cod => colors.codSurface,
    };
    final borderColor = tone == NokiSurfaceTone.cod
        ? colors.codAccent
        : tone == NokiSurfaceTone.inverse
        ? colors.chromeBorder
        : colors.border;

    final card = AnimatedContainer(
      duration: NokiMotion.duration(context, const Duration(milliseconds: 180)),
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
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadowColor.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
      NokiBadgeTone.offline => (colors.offlineSurface, colors.offline),
      NokiBadgeTone.cod => (colors.codSurface, colors.codAccentInk),
      NokiBadgeTone.neutral => (colors.surfaceSubtle, colors.textPrimary),
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
          color: tone == NokiBadgeTone.offline || tone == NokiBadgeTone.neutral
              ? colors.border
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
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.$2,
                fontWeight: FontWeight.w600,
              ),
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
      NokiBadgeTone.success => (colors.successSurface, colors.success),
      NokiBadgeTone.offline => (colors.chromeSurface, colors.chromeInk),
      _ => (colors.surfaceSubtle, colors.textPrimary),
    };

    return Container(
      padding: EdgeInsets.all(metrics.cardPadding),
      decoration: BoxDecoration(
        color: scheme.$1,
        borderRadius: BorderRadius.circular(metrics.radiusCard),
        border: Border.all(
          color: tone == NokiBadgeTone.offline
              ? colors.chromeBorder
              : scheme.$2.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.$2, size: metrics.iconMedium),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.$2),
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: AppSpacing.md),
            action!,
          ],
        ],
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: emphasis ? colors.surfaceSelected : colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(metrics.radiusButton),
        border: Border.all(
          color: emphasis
              ? colors.actionPrimary.withValues(alpha: 0.50)
              : colors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: metrics.badgeIconSize,
            color: emphasis ? colors.textPrimary : colors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: emphasis ? colors.textPrimary : colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
