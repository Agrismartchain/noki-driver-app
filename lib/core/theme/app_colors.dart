import 'package:flutter/widgets.dart';

/// Semantic color tokens mirrored from the NOKI design system
/// (`noki-design-system/src/tokens/source/color.json` and `theme-dark.json`).
///
/// These are NOT imported from the design system package - it is a
/// TypeScript/React library and cannot be consumed from Flutter. Every value
/// below was read from the JSON token source and re-expressed as a Dart
/// constant, keeping the same semantic names so a design change on the web
/// side has an obvious counterpart to update here.
class NokiColors {
  const NokiColors._();

  static const light = NokiColorScheme(
    background: Color(0xFFF9F9F9),
    surface: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFF3F3F3),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceSelected: Color(0xFFFFFACF),
    chromeSurface: Color(0xFF1A1A1A),
    chromeSurfaceRaised: Color(0xFF2A2A2A),
    chromeBorder: Color(0x332A2A2A),
    chromeInk: Color(0xFFFFFFFF),
    border: Color(0xFFE5E5E5),
    borderSubtle: Color(0xFFEDEDED),
    borderStrong: Color(0xFFCFCFCF),
    textPrimary: Color(0xFF1A1C1C),
    textSecondary: Color(0xFF474832),
    textMuted: Color(0xFF6B6C58),
    textInverse: Color(0xFFFFFFFF),
    actionPrimary: Color(0xFFF5FF00),
    actionPrimaryHover: Color(0xFFE3EC00),
    actionPrimarySubtle: Color(0xFFF7FF8A),
    actionPrimaryInk: Color(0xFF111111),
    actionDanger: Color(0xFFB91C1C),
    focus: Color(0xFFF5FF00),
    brandAccent: Color(0xFFF5FF00),
    brandAccentInk: Color(0xFF111111),
    info: Color(0xFF1565C0),
    infoSurface: Color(0xFFEAF4FF),
    success: Color(0xFF2E7D32),
    successSurface: Color(0xFFEAF8EF),
    warning: Color(0xFFB45309),
    warningSurface: Color(0xFFFFF4E5),
    danger: Color(0xFFC62828),
    dangerSurface: Color(0xFFFFECEA),
    offline: Color(0xFF4A4A4A),
    offlineSurface: Color(0xFFECECEC),
    codAccent: Color(0xFF00D1FF),
    codAccentInk: Color(0xFF0E3B47),
    codSurface: Color(0xFFF0FDFF),
    financePositive: Color(0xFF111111),
    financeNegative: Color(0xFFB91C1C),
    financePending: Color(0xFF0E3B47),
    shadowColor: Color(0xFF000000),
  );

  static const dark = NokiColorScheme(
    background: Color(0xFF121212),
    surface: Color(0xFF1A1A1A),
    surfaceSubtle: Color(0xFF242424),
    surfaceElevated: Color(0xFF1E1E1E),
    surfaceSelected: Color(0xFF2D2C12),
    chromeSurface: Color(0xFF0E0E0E),
    chromeSurfaceRaised: Color(0xFF1D1D1D),
    chromeBorder: Color(0x44F5FF00),
    chromeInk: Color(0xFFFFFFFF),
    border: Color(0xFF303030),
    borderSubtle: Color(0xFF262626),
    borderStrong: Color(0xFF4A4A4A),
    textPrimary: Color(0xFFF8F8F8),
    textSecondary: Color(0xFFD0D0BE),
    textMuted: Color(0xFFA8A8A8),
    textInverse: Color(0xFF121212),
    actionPrimary: Color(0xFFE9D64A),
    actionPrimaryHover: Color(0xFFF5FF00),
    actionPrimarySubtle: Color(0xFF3E4100),
    actionPrimaryInk: Color(0xFF111111),
    actionDanger: Color(0xFFF44336),
    focus: Color(0xFFF5FF00),
    brandAccent: Color(0xFFF5FF00),
    brandAccentInk: Color(0xFF111111),
    info: Color(0xFF71C9FF),
    infoSurface: Color(0xFF122A38),
    success: Color(0xFF6FD372),
    successSurface: Color(0xFF17311A),
    warning: Color(0xFFF59E0B),
    warningSurface: Color(0xFF3A2C12),
    danger: Color(0xFFFF8A80),
    dangerSurface: Color(0xFF381A18),
    offline: Color(0xFFD6D6D6),
    offlineSurface: Color(0xFF2C2C2C),
    codAccent: Color(0xFF00D1FF),
    codAccentInk: Color(0xFFE1FBFF),
    codSurface: Color(0xFF0E1A1C),
    financePositive: Color(0xFFFFFFFF),
    financeNegative: Color(0xFFFF8A80),
    financePending: Color(0xFFE1FBFF),
    shadowColor: Color(0xFF000000),
  );
}

class NokiColorScheme {
  const NokiColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceSubtle,
    required this.surfaceElevated,
    required this.surfaceSelected,
    required this.chromeSurface,
    required this.chromeSurfaceRaised,
    required this.chromeBorder,
    required this.chromeInk,
    required this.border,
    required this.borderSubtle,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textInverse,
    required this.actionPrimary,
    required this.actionPrimaryHover,
    required this.actionPrimarySubtle,
    required this.actionPrimaryInk,
    required this.actionDanger,
    required this.focus,
    required this.brandAccent,
    required this.brandAccentInk,
    required this.info,
    required this.infoSurface,
    required this.success,
    required this.successSurface,
    required this.warning,
    required this.warningSurface,
    required this.danger,
    required this.dangerSurface,
    required this.offline,
    required this.offlineSurface,
    required this.codAccent,
    required this.codAccentInk,
    required this.codSurface,
    required this.financePositive,
    required this.financeNegative,
    required this.financePending,
    required this.shadowColor,
  });

  final Color background;
  final Color surface;
  final Color surfaceSubtle;
  final Color surfaceElevated;
  final Color surfaceSelected;
  final Color chromeSurface;
  final Color chromeSurfaceRaised;
  final Color chromeBorder;
  final Color chromeInk;
  final Color border;
  final Color borderSubtle;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textInverse;
  final Color actionPrimary;
  final Color actionPrimaryHover;
  final Color actionPrimarySubtle;
  final Color actionPrimaryInk;
  final Color actionDanger;
  final Color focus;
  final Color brandAccent;
  final Color brandAccentInk;
  final Color info;
  final Color infoSurface;
  final Color success;
  final Color successSurface;
  final Color warning;
  final Color warningSurface;
  final Color danger;
  final Color dangerSurface;
  final Color offline;
  final Color offlineSurface;
  final Color codAccent;
  final Color codAccentInk;
  final Color codSurface;
  final Color financePositive;
  final Color financeNegative;
  final Color financePending;
  final Color shadowColor;
}
