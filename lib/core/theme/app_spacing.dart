/// Spacing scale, mirrored from `noki-design-system/src/tokens/source/spacing.json`
/// conventions (a 4pt base grid). Used instead of scattering magic numbers
/// through layout code.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double page = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Corner radius scale, mirrored from `radius.json`.
class AppRadius {
  const AppRadius._();

  static const double sm = 6;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

class AppBorderWidth {
  const AppBorderWidth._();

  static const double sm = 1;
  static const double md = 1.5;
}

class AppControlSize {
  const AppControlSize._();

  static const double minTouchTarget = 48;
  static const double primaryButtonHeight = 56;
  static const double navigationBarHeight = 74;
}
