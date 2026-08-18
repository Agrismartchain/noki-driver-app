import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/i18n/locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to French once restored', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(localeProvider.notifier).ready;
    expect(container.read(localeProvider), const Locale('fr'));
  });

  test('setLocale switches to Arabic and persists it', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(localeProvider.notifier).ready;

    await container.read(localeProvider.notifier).setLocale(const Locale('ar'));
    expect(container.read(localeProvider), const Locale('ar'));

    final restored = ProviderContainer();
    addTearDown(restored.dispose);
    await restored.read(localeProvider.notifier).ready;
    expect(restored.read(localeProvider), const Locale('ar'));
  });

  test('an unsupported stored locale code falls back to the default', () async {
    SharedPreferences.setMockInitialValues({'noki.settings.locale': 'es'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(localeProvider.notifier).ready;
    expect(container.read(localeProvider), defaultLocale);
  });
}
