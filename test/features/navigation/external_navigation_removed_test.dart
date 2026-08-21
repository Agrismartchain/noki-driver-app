import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Cheap, deterministic static guard for mandate §65's
/// "GOOGLE_NAVIGATION_REFERENCES=0 / WAZE_NAVIGATION_REFERENCES=0"
/// requirement: navigation is in-app only, so no source file in the
/// delivery/mobility navigation surfaces may hand the driver off to an
/// external maps app. `tel:` phone calls are explicitly out of scope for
/// this guard - they are not a navigation handoff (mandate §46).
void main() {
  final files = [
    'lib/features/delivery/delivery_mission_detail_screen.dart',
    'lib/features/delivery/delivery_mission_map_screen.dart',
    'lib/features/mobility/mobility_ride_screen.dart',
    'lib/features/mobility/mobility_ride_map_screen.dart',
  ];

  for (final path in files) {
    test('$path contains no external navigation handoff', () {
      final contents = File(path).readAsStringSync();

      expect(
        contents.contains('geo:'),
        isFalse,
        reason: '$path still references the geo: URI scheme',
      );
      expect(
        contents.contains('waze:'),
        isFalse,
        reason: '$path still references a Waze deep link',
      );
      expect(
        contents.contains('com.google.android.apps.maps'),
        isFalse,
        reason: '$path still references the Google Maps Android package',
      );

      // A `launchUrl` call combined with a maps/waze-flavored URI is the
      // real external-handoff pattern - `launchUrl(Uri(scheme: 'tel', ...))`
      // for phone calls must remain untouched by this guard.
      final hasLaunchUrl = contents.contains('launchUrl');
      final hasMapsPattern = RegExp(
        r'google\.com/maps|maps\.google|waze',
        caseSensitive: false,
      ).hasMatch(contents);
      expect(
        hasLaunchUrl && hasMapsPattern,
        isFalse,
        reason:
            '$path combines launchUrl with a maps/waze pattern - external navigation handoff',
      );
    });
  }
}
