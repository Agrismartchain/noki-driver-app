import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePrefsKey = 'noki.settings.locale';

/// Supported locales for DRIVER-APP-01. French is the default, matching
/// NOKI's primary operating markets; English and Arabic (RTL) are the other
/// two mandated locales.
const supportedLocales = [Locale('fr'), Locale('en'), Locale('ar')];
const defaultLocale = Locale('fr');

class LocaleController extends Notifier<Locale?> {
  /// Resolves once the persisted preference (or the default) has been
  /// loaded. See `ThemeModeController.ready` for why this is exposed.
  late final Future<void> ready;

  @override
  Locale? build() {
    ready = _restore();
    return null; // null => follow system locale until a preference is loaded/set.
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_localePrefsKey);
    if (stored == null) {
      state = defaultLocale;
      return;
    }
    final match = supportedLocales.where((l) => l.languageCode == stored);
    state = match.isNotEmpty ? match.first : defaultLocale;
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefsKey, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale?>(LocaleController.new);
