import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Static validation of the minimum platform setup behind B4/DRV-05's
/// active-work background tracking (see GpsPublisherController): a visible
/// foreground service on Android, background location mode on iOS - and
/// nothing broader ("Always" / ACCESS_BACKGROUND_LOCATION stays out).
void main() {
  test('Android manifest declares only the foreground-service location permissions it needs', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync()
        .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    expect(manifest, contains('android.permission.ACCESS_FINE_LOCATION'));
    expect(manifest, contains('android.permission.FOREGROUND_SERVICE"'));
    expect(manifest, contains('android.permission.FOREGROUND_SERVICE_LOCATION'));
    // Least privilege: the foreground service is started while the app is visible, so the
    // invasive "all the time" permission is deliberately NOT requested.
    expect(manifest, isNot(contains('ACCESS_BACKGROUND_LOCATION')));
  });

  test('iOS enables the location background mode but asks no "Always" authorization', () {
    final plist = File('ios/Runner/Info.plist')
        .readAsStringSync()
        .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    expect(plist, contains('<key>UIBackgroundModes</key>'));
    expect(plist, contains('<string>location</string>'));
    expect(plist, contains('NSLocationWhenInUseUsageDescription'));
    expect(plist, isNot(contains('NSLocationAlwaysAndWhenInUseUsageDescription')));
    expect(plist, isNot(contains('NSLocationAlwaysUsageDescription')));
  });
}
