import 'package:flutter/widgets.dart';

/// Central place every decorative (non-functional) animation in the app
/// reads its duration from, so the OS "reduce motion" accessibility setting
/// (`MediaQuery.disableAnimations` - Android's "Remove animations", iOS's
/// "Reduce Motion") is honored everywhere instead of screen-by-screen.
///
/// Deliberately conservative: this only ever shortens a *decorative*
/// transition (splash entrance, nav-bar selection indicator, card press
/// affordance) down to [Duration.zero] - it never touches a functional
/// loading spinner, nor any Mobility/Delivery state transition, both of
/// which must keep running regardless of this setting.
class NokiMotion {
  const NokiMotion._();

  /// [normal] when the platform allows animations, [Duration.zero]
  /// (effectively instant, no animation) when the driver has turned on
  /// "reduce motion"/"remove animations" at the OS level.
  static Duration duration(BuildContext context, Duration normal) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false
        ? Duration.zero
        : normal;
  }
}
