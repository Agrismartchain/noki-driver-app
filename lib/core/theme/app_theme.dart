import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Builds a Material [ThemeData] from the NOKI semantic color scheme.
///
/// Centralized here so no widget in `features/` ever reads a raw [Color]
/// literal - everything goes through `Theme.of(context).colorScheme` or the
/// [NokiTheme] extension registered below.
ThemeData buildNokiTheme(NokiColorScheme colors, Brightness brightness) {
  final colorScheme = brightness == Brightness.light
      ? ColorScheme.light(
          surface: colors.surface,
          onSurface: colors.textPrimary,
          primary: colors.actionPrimary,
          onPrimary: colors.actionPrimaryInk,
          secondary: colors.brandAccent,
          onSecondary: colors.brandAccentInk,
          error: colors.danger,
          onError: colors.textInverse,
          outline: colors.border,
        )
      : ColorScheme.dark(
          surface: colors.surface,
          onSurface: colors.textPrimary,
          primary: colors.actionPrimary,
          onPrimary: colors.actionPrimaryInk,
          secondary: colors.brandAccent,
          onSecondary: colors.brandAccentInk,
          error: colors.danger,
          onError: colors.textInverse,
          outline: colors.border,
        );

  final textTheme = TextTheme(
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
      fontSize: AppTypography.sizeLg,
      fontWeight: AppTypography.weightSemibold,
      height: AppTypography.lineHeightNormal,
      color: colors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: AppTypography.sizeMd,
      fontWeight: AppTypography.weightRegular,
      height: AppTypography.lineHeightNormal,
      color: colors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: AppTypography.sizeSm,
      fontWeight: AppTypography.weightRegular,
      height: AppTypography.lineHeightNormal,
      color: colors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: AppTypography.sizeSm,
      fontWeight: AppTypography.weightMedium,
      letterSpacing: AppTypography.letterSpacingWide,
      color: colors.textPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: AppTypography.sizeXs,
      fontWeight: AppTypography.weightMedium,
      letterSpacing: AppTypography.letterSpacingWide,
      color: colors.textMuted,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colors.background,
    textTheme: textTheme,
    // No `fontFamily` override: see AppTypography doc comment for the
    // platform-system-font fallback rationale (Helvetica is not embeddable).
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: colors.surfaceElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colors.border),
      ),
    ),
    dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceSubtle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.focus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.danger),
      ),
      labelStyle: TextStyle(color: colors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.actionPrimary,
        foregroundColor: colors.actionPrimaryInk,
        disabledBackgroundColor: colors.border,
        disabledForegroundColor: colors.textMuted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: textTheme.labelLarge,
      ),
    ),
    extensions: [NokiTheme(colors: colors)],
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
  NokiTheme copyWith({NokiColorScheme? colors}) => NokiTheme(colors: colors ?? this.colors);

  @override
  NokiTheme lerp(ThemeExtension<NokiTheme>? other, double t) {
    if (other is! NokiTheme) return this;
    return t < 0.5 ? this : other;
  }
}

extension NokiThemeContext on BuildContext {
  NokiColorScheme get nokiColors => Theme.of(this).extension<NokiTheme>()!.colors;
}
