import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds a Material [ThemeData] from the NOKI semantic color scheme.
///
/// Centralized here so no widget in `features/` ever reads a raw [Color]
/// literal - everything goes through `Theme.of(context).colorScheme` or the
/// [NokiTheme] extension registered below.
ThemeData buildNokiTheme(NokiColorScheme colors, Brightness brightness) {
  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: colors.actionPrimary,
    onPrimary: colors.actionPrimaryInk,
    primaryContainer: colors.actionPrimarySubtle,
    onPrimaryContainer: colors.actionPrimaryInk,
    secondary: colors.codAccent,
    onSecondary: colors.codAccentInk,
    secondaryContainer: colors.codSurface,
    onSecondaryContainer: colors.codAccentInk,
    tertiary: colors.chromeSurface,
    onTertiary: colors.textInverse,
    tertiaryContainer: colors.surfaceSubtle,
    onTertiaryContainer: colors.textPrimary,
    error: colors.danger,
    onError: colors.textInverse,
    errorContainer: colors.dangerSurface,
    onErrorContainer: colors.danger,
    surface: colors.surface,
    onSurface: colors.textPrimary,
    surfaceContainerHighest: colors.surfaceElevated,
    outline: colors.border,
    outlineVariant: colors.borderSubtle,
    shadow: colors.shadowColor,
    scrim: colors.shadowColor,
    inverseSurface: colors.chromeSurface,
    onInverseSurface: colors.textInverse,
    inversePrimary: colors.actionPrimaryHover,
  );

  final textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: AppTypography.size4xl,
      fontWeight: AppTypography.weightExtraBold,
      height: AppTypography.lineHeightDense,
      letterSpacing: AppTypography.letterSpacingTight,
      color: colors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: AppTypography.size3xl,
      fontWeight: AppTypography.weightBold,
      height: AppTypography.lineHeightTight,
      color: colors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: AppTypography.size2xl,
      fontWeight: AppTypography.weightSemibold,
      height: AppTypography.lineHeightTight,
      color: colors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: AppTypography.sizeXl,
      fontWeight: AppTypography.weightSemibold,
      height: AppTypography.lineHeightNormal,
      color: colors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: AppTypography.sizeLg,
      fontWeight: AppTypography.weightSemibold,
      height: AppTypography.lineHeightNormal,
      color: colors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: AppTypography.sizeLg,
      fontWeight: AppTypography.weightMedium,
      height: AppTypography.lineHeightNormal,
      color: colors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: AppTypography.sizeLg,
      fontWeight: AppTypography.weightRegular,
      height: AppTypography.lineHeightNormal,
      color: colors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: AppTypography.sizeMd,
      fontWeight: AppTypography.weightRegular,
      height: AppTypography.lineHeightNormal,
      color: colors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: AppTypography.sizeMd,
      fontWeight: AppTypography.weightBold,
      letterSpacing: AppTypography.letterSpacingButton,
      color: colors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: AppTypography.sizeMd,
      fontWeight: AppTypography.weightMedium,
      height: AppTypography.lineHeightTight,
      color: colors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontSize: AppTypography.sizeSm,
      fontWeight: AppTypography.weightMedium,
      letterSpacing: AppTypography.letterSpacingWide + 0.2,
      color: colors.textMuted,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colors.background,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    // No `fontFamily` override: see AppTypography doc comment for the
    // platform-system-font fallback rationale (Helvetica is not embeddable).
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: textTheme.titleMedium,
      toolbarHeight: AppControlSize.minTouchTarget + AppSpacing.sm,
    ),
    cardTheme: CardThemeData(
      color: colors.surfaceElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.border),
      ),
    ),
    dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      side: BorderSide(color: colors.border),
      backgroundColor: colors.surfaceSubtle,
      selectedColor: colors.actionPrimary,
      secondarySelectedColor: colors.actionPrimary,
      labelStyle: textTheme.labelMedium?.copyWith(color: colors.textPrimary),
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(
        color: colors.actionPrimaryInk,
      ),
      disabledColor: colors.surfaceSubtle,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceSubtle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.focus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.danger, width: 2),
      ),
      labelStyle: TextStyle(color: colors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.actionPrimary,
        foregroundColor: colors.actionPrimaryInk,
        disabledBackgroundColor: colors.border,
        disabledForegroundColor: colors.textMuted,
        minimumSize: const Size.fromHeight(AppControlSize.primaryButtonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        minimumSize: const Size.fromHeight(AppControlSize.primaryButtonHeight),
        side: BorderSide(color: colors.borderStrong),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.textPrimary,
        textStyle: textTheme.labelMedium,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colors.textPrimary,
        minimumSize: const Size.square(AppControlSize.minTouchTarget),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.actionPrimary;
          }
          return colors.surfaceSubtle;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.actionPrimaryInk;
          }
          return colors.textSecondary;
        }),
        side: WidgetStatePropertyAll(BorderSide(color: colors.border)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        textStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.chromeSurface,
      indicatorColor: Colors.transparent,
      height: AppControlSize.navigationBarHeight,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelSmall?.copyWith(
          color: selected ? colors.actionPrimary : colors.textMuted,
          fontWeight: selected
              ? AppTypography.weightBold
              : AppTypography.weightMedium,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? colors.actionPrimary : colors.textMuted,
          size: 24,
        );
      }),
      surfaceTintColor: Colors.transparent,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.actionPrimary,
      linearTrackColor: colors.surfaceSubtle,
      circularTrackColor: colors.surfaceSubtle,
    ),
    extensions: [
      NokiTheme(colors: colors),
      NokiMetricsTheme(
        data: const NokiMetrics(
          radiusButton: AppRadius.md,
          radiusCard: AppRadius.lg,
          radiusPill: AppRadius.full,
          borderWidth: AppBorderWidth.sm,
          borderWidthEmphasis: AppBorderWidth.md,
          cardPadding: AppSpacing.lg,
          pagePadding: AppSpacing.page,
          sectionGap: AppSpacing.xl,
          badgeHorizontalPadding: AppSpacing.md,
          badgeVerticalPadding: AppSpacing.sm,
          badgeIconSize: 14,
          iconMedium: 18,
          heroIconSize: 40,
          safeAreaInset: AppSpacing.sm,
        ),
      ),
    ],
  );
}

/// Theme extension exposing the full semantic NOKI color set beyond what
/// Material's [ColorScheme] models (success/warning/info surfaces, muted
/// text, etc.), so widgets can do `Theme.of(context).nokiColors.success`.
@immutable
class NokiTheme extends ThemeExtension<NokiTheme> {
  const NokiTheme({required this.colors});

  final NokiColorScheme colors;

  @override
  NokiTheme copyWith({NokiColorScheme? colors}) =>
      NokiTheme(colors: colors ?? this.colors);

  @override
  NokiTheme lerp(ThemeExtension<NokiTheme>? other, double t) {
    if (other is! NokiTheme) return this;
    return t < 0.5 ? this : other;
  }
}

extension NokiThemeContext on BuildContext {
  NokiColorScheme get nokiColors =>
      Theme.of(this).extension<NokiTheme>()!.colors;

  NokiMetrics get nokiMetrics =>
      Theme.of(this).extension<NokiMetricsTheme>()!.data;
}

@immutable
class NokiMetricsTheme extends ThemeExtension<NokiMetricsTheme> {
  const NokiMetricsTheme({required this.data});

  final NokiMetrics data;

  @override
  NokiMetricsTheme copyWith({NokiMetrics? data}) =>
      NokiMetricsTheme(data: data ?? this.data);

  @override
  NokiMetricsTheme lerp(ThemeExtension<NokiMetricsTheme>? other, double t) {
    if (other is! NokiMetricsTheme) return this;
    return t < 0.5 ? this : other;
  }
}

@immutable
class NokiMetrics {
  const NokiMetrics({
    required this.radiusButton,
    required this.radiusCard,
    required this.radiusPill,
    required this.borderWidth,
    required this.borderWidthEmphasis,
    required this.cardPadding,
    required this.pagePadding,
    required this.sectionGap,
    required this.badgeHorizontalPadding,
    required this.badgeVerticalPadding,
    required this.badgeIconSize,
    required this.iconMedium,
    required this.heroIconSize,
    required this.safeAreaInset,
  });

  final double radiusButton;
  final double radiusCard;
  final double radiusPill;
  final double borderWidth;
  final double borderWidthEmphasis;
  final double cardPadding;
  final double pagePadding;
  final double sectionGap;
  final double badgeHorizontalPadding;
  final double badgeVerticalPadding;
  final double badgeIconSize;
  final double iconMedium;
  final double heroIconSize;
  final double safeAreaInset;
}
