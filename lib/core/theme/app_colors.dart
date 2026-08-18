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
    background: Color(0xFFF5F6F8),
    surface: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFF5F6F8),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceSelected: Color(0xFFFFFACF),
    border: Color(0xFFE3E5EA),
    borderSubtle: Color(0xFFE9E9EE),
    borderStrong: Color(0xFFDDE2EA),
    textPrimary: Color(0xFF343442),
    textSecondary: Color(0xFF6E6F82),
    textMuted: Color(0xFF9293A1),
    textInverse: Color(0xFFFFFFFF),
    actionPrimary: Color(0xFFA99724),
    actionPrimaryHover: Color(0xFFD6C137),
    actionPrimarySubtle: Color(0xFFFFFACF),
    actionPrimaryInk: Color(0xFF25252D),
    actionDanger: Color(0xFFB91C1C),
    focus: Color(0xFFA99724),
    brandAccent: Color(0xFFFFD500),
    brandAccentInk: Color(0xFF171200),
    info: Color(0xFF0E7490),
    infoSurface: Color(0xFFEAFBFD),
    success: Color(0xFF047857),
    successSurface: Color(0xFFEAF8EF),
    warning: Color(0xFFB45309),
    warningSurface: Color(0xFFFFF4E5),
    danger: Color(0xFFB91C1C),
    dangerSurface: Color(0xFFFDEBEC),
  );

  static const dark = NokiColorScheme(
    background: Color(0xFF0E1117),
    surface: Color(0xFF161A24),
    surfaceSubtle: Color(0xFF1C2130),
    surfaceElevated: Color(0xFF1D2333),
    surfaceSelected: Color(0xFF2A2A1E),
    border: Color(0xFF262B3A),
    borderSubtle: Color(0xFF1E2330),
    borderStrong: Color(0xFF323852),
    textPrimary: Color(0xFFF1F3F9),
    textSecondary: Color(0xFFA9AEC2),
    textMuted: Color(0xFF6E7390),
    textInverse: Color(0xFF171200),
    actionPrimary: Color(0xFFE9D64A),
    actionPrimaryHover: Color(0xFFF2E05D),
    actionPrimarySubtle: Color(0xFF3A331A),
    actionPrimaryInk: Color(0xFF171200),
    actionDanger: Color(0xFFDC2626),
    focus: Color(0xFFE9D64A),
    brandAccent: Color(0xFFFFD500),
    brandAccentInk: Color(0xFF171200),
    info: Color(0xFF06B6D4),
    infoSurface: Color(0xFF16323A),
    success: Color(0xFF059669),
    successSurface: Color(0xFF14352A),
    warning: Color(0xFFF59E0B),
    warningSurface: Color(0xFF3A2C12),
    danger: Color(0xFFDC2626),
    dangerSurface: Color(0xFF3A1B1C),
  );
}

class NokiColorScheme {
  const NokiColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceSubtle,
    required this.surfaceElevated,
    required this.surfaceSelected,
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
  });

  final Color background;
  final Color surface;
  final Color surfaceSubtle;
  final Color surfaceElevated;
  final Color surfaceSelected;
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
}
