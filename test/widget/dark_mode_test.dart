import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';

void main() {
  test('buildNokiTheme(light) uses the light NOKI background token', () {
    final theme = buildNokiTheme(NokiColors.light, Brightness.light);
    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, NokiColors.light.background);
  });

  test('buildNokiTheme(dark) uses the dark NOKI background token, not an inverted light one', () {
    final theme = buildNokiTheme(NokiColors.dark, Brightness.dark);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, NokiColors.dark.background);
    expect(theme.scaffoldBackgroundColor, isNot(NokiColors.light.background));
  });

  testWidgets('a widget under the dark theme resolves dark NokiColors via the theme extension', (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildNokiTheme(NokiColors.dark, Brightness.dark),
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const Scaffold();
          },
        ),
      ),
    );

    expect(capturedContext.nokiColors.background, NokiColors.dark.background);
    expect(Theme.of(capturedContext).brightness, Brightness.dark);
  });
}
