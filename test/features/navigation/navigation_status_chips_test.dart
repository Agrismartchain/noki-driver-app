import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/i18n/generated/app_localizations.dart';
import 'package:noki_driver_app/core/theme/app_colors.dart';
import 'package:noki_driver_app/core/theme/app_theme.dart';
import 'package:noki_driver_app/features/map/map_point.dart';
import 'package:noki_driver_app/features/navigation/navigation_route.dart';
import 'package:noki_driver_app/features/navigation/navigation_status_chips.dart';

void main() {
  testWidgets(
    'long Arabic maneuver text wraps inside the status chip without a RenderFlex overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      const maneuverInstruction =
          'انعطف يمينا قليلا ثم تابع السير لمسافة طويلة باتجاه شارع الزرقطوني '
          'مع الالتزام بالمسار الأيمن حتى نقطة الالتقاء التالية';
      const route = NavigationRoute(
        geometry: [MapPoint(33.59, -7.61), MapPoint(33.58, -7.60)],
        distanceMeters: 24100,
        durationSeconds: 1800,
        profile: ComputeDriverRouteResponseDtoProfile.auto,
        maneuvers: [
          NavigationManeuver(
            type: 'turn',
            modifier: 'slight right',
            instruction: maneuverInstruction,
            distanceMeters: 350,
            durationSeconds: 60,
            location: MapPoint(33.585, -7.605),
            streetName: 'Boulevard Zerktouni',
          ),
        ],
        providerStatus: ComputeDriverRouteResponseDtoProviderStatus.ok,
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: buildNokiTheme(NokiColors.light, Brightness.light),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(320, 700)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Builder(
                  builder: (context) => Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 320 - 32,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: navigationStatusChips(
                          context,
                          route: route,
                          onRetry: () {},
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final maneuverTextFinder = find.textContaining('الزرقطوني');
      expect(maneuverTextFinder, findsOneWidget);

      final wrapBox = tester.renderObject<RenderBox>(find.byType(Wrap));
      final textBox = tester.renderObject<RenderBox>(maneuverTextFinder);
      expect(textBox.size.width, lessThanOrEqualTo(wrapBox.size.width));
    },
  );
}
