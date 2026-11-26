import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/app/splash_screen.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';

/// Previously entirely untested (see the night QA report) - this is the
/// first coverage for [SplashScreen]'s entrance animation and its
/// reduce-motion behavior.
///
/// Deliberately pumps a bounded number of frames instead of
/// `pumpAndSettle()`: the screen's own `CircularProgressIndicator` is an
/// indeterminate, never-ending animation by design (real bootstrap work is
/// in flight for as long as the splash is shown) - `pumpAndSettle` would
/// time out waiting for an animation that never finishes.
Future<void> _pumpSplash(
  WidgetTester tester, {
  bool reduceMotion = false,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: MaterialApp(
        theme: buildNokiTheme(NokiColors.light, Brightness.light),
        home: const SplashScreen(),
      ),
    ),
  );
  // One frame for the initial (pre-entrance) build, one more for the
  // post-frame callback's setState driving the entrance to "settled".
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('shows the NOKI brand mark and wordmark, settled after a frame', (
    tester,
  ) async {
    await _pumpSplash(tester);

    expect(find.text('NOKI DRIVER'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(
      opacity.opacity,
      1,
      reason: 'entrance animation must have settled to fully visible',
    );
  });

  testWidgets(
    'collapses the entrance animation to an instant cut when the OS reduce-motion setting is on',
    (tester) async {
      await _pumpSplash(tester, reduceMotion: true);

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(
        opacity.duration,
        Duration.zero,
        reason: 'reduce motion must collapse the fade-in to an instant cut',
      );
      expect(
        scale.duration,
        Duration.zero,
        reason: 'reduce motion must collapse the scale-in to an instant cut',
      );
    },
  );
}
