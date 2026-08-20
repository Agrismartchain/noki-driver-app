import 'package:flutter/widgets.dart';

/// Type scale mirrored from `noki-design-system/src/tokens/source/typography.json`.
///
/// Font family strategy (see README "Typography" section for the full
/// rationale required by DRIVER-APP-01 section 26): the design system's
/// source-of-truth family is `Helvetica, "Helvetica Neue", Arial, sans-serif`.
/// Helvetica is not a font this repository can legally embed (no licensed
/// .ttf/.otf ships with the monorepo, and it must not be downloaded from the
/// internet). Flutter's default text theme falls back to each platform's
/// native system font when no `fontFamily` is set on the app-level
/// `TextTheme` - Roboto on Android, San Francisco on iOS - which is the
/// documented, legally-safe fallback used here. No `fontFamily` is set below;
/// only weight/size/height/letter-spacing tokens are applied.
class AppTypography {
  const AppTypography._();

  static const double sizeXs = 11;
  static const double sizeSm = 12;
  static const double sizeMd = 14;
  static const double sizeLg = 16;
  static const double sizeXl = 18;
  static const double size2xl = 20;
  static const double size3xl = 24;
  static const double size4xl = 32;

  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightExtraBold = FontWeight.w800;

  static const double lineHeightDense = 1.0;
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.45;
  static const double lineHeightRelaxed = 1.55;

  static const double letterSpacingWide = 0.15; // ~0.01em at sizeMd
  static const double letterSpacingButton = 0.7;
  static const double letterSpacingTight = -0.8;
}
