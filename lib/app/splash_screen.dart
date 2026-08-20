import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/ui/noki_ui.dart';

/// Blocking splash shown only while the session is being restored/validated
/// (`AuthStatus.bootstrapping`). No operational data is fetched or shown
/// here - see README "Session bootstrap".
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;

    return Scaffold(
      body: NokiScreenBackground(
        safeTop: true,
        safeBottom: true,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colors.actionPrimary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadowColor.withValues(alpha: 0.18),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.north_east,
                  size: 44,
                  color: colors.actionPrimaryInk,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'NOKI DRIVER',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: colors.actionPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
