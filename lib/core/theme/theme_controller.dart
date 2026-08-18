import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePrefsKey = 'noki.settings.theme_mode';

class ThemeModeController extends Notifier<ThemeMode> {
  /// Resolves once the persisted preference (if any) has been loaded.
  /// Exposed so tests can await restoration deterministically instead of
  /// guessing how many event-loop turns `SharedPreferences.getInstance()`
  /// needs.
  late final Future<void> ready;

  @override
  ThemeMode build() {
    ready = _restore();
    return ThemeMode.system;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeModePrefsKey);
    final restored = _parse(stored);
    if (restored != state) state = restored;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefsKey, mode.name);
  }

  ThemeMode _parse(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
