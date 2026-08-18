/// Spacing scale, mirrored from `noki-design-system/src/tokens/source/spacing.json`
/// conventions (a 4pt base grid). Used instead of scattering magic numbers
/// through layout code.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Corner radius scale, mirrored from `radius.json`.
class AppRadius {
  const AppRadius._();

  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double full = 999;
}
