import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/motion.dart';
import '../core/ui/noki_ui.dart';

/// Blocking splash shown only while the session is being restored/validated
/// (`AuthStatus.bootstrapping`). No operational data is fetched or shown
/// here - see README "Session bootstrap".
///
/// Plays one light entrance animation (brand mark fades/scales in) the
/// instant it is first shown - never gated behind an artificial delay, since
/// how long the splash stays on screen is entirely driven by how long real
/// session bootstrap genuinely takes (`AuthController._bootstrap` /
/// `RootGate`), not by this animation. [NokiMotion.duration] collapses it to
/// [Duration.zero] (brand mark appears instantly, fully settled) when the
/// driver has "reduce motion"/"remove animations" on at the OS level.
///
/// The brand mark is the real NOKI mark already shipped in this repo as the
/// Android launcher icon (`assets/brand/noki_logo.png`, a copy of
/// `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`) - not an
/// invented placeholder glyph.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    // Deferred to the frame after the first build, so the entrance has a
    // real 0 -> 1 transition to animate instead of starting already-visible.
    // This is scheduling, not a delay: nothing here ever postpones the
    // real redirect away from Splash once auth status resolves - if that
    // happens before this callback fires, `mounted` is simply false and the
    // callback is a no-op.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _settled = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.nokiColors;
    final duration = NokiMotion.duration(
      context,
      const Duration(milliseconds: 420),
    );

    return Scaffold(
      body: NokiScreenBackground(
        safeTop: true,
        safeBottom: true,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                opacity: _settled ? 1 : 0,
                duration: duration,
                curve: Curves.easeOut,
                child: AnimatedScale(
                  scale: _settled ? 1 : 0.88,
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadowColor.withValues(alpha: 0.18),
                          blurRadius: 26,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/brand/noki_logo.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'NOKI DRIVER',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              // The loading spinner is a functional progress signal (real
              // bootstrap work is in flight), not decoration - it keeps
              // spinning regardless of the reduce-motion setting above.
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
