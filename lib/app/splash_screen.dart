import 'package:flutter/material.dart';

/// Blocking splash shown only while the session is being restored/validated
/// (`AuthStatus.bootstrapping`). No operational data is fetched or shown
/// here - see README "Session bootstrap".
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
