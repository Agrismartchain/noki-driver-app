import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/noki_driver_app.dart';
import 'core/config/app_environment.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Fail closed: an unsafe/incomplete release configuration refuses to
    // start instead of running against development defaults.
    AppConfig.fromDefines();
  } on StateError catch (error) {
    runApp(ConfigErrorApp(message: error.message));
    return;
  } on ArgumentError catch (error) {
    runApp(ConfigErrorApp(message: '${error.message}'));
    return;
  }
  runApp(const ProviderScope(child: NokiDriverApp()));
}

/// Blocking screen shown when the build configuration is invalid.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Configuration invalide',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
