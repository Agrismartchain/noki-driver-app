import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/motion.dart';
import '../features/auth/auth_providers.dart';
import '../features/auth/auth_state.dart';
import 'home_shell.dart';
import 'splash_screen.dart';

/// Resolves to either the blocking splash (while bootstrapping) or the
/// authenticated home shell. Unauthenticated/access-denied states never
/// reach here - `app_router.dart` redirects them away first.
///
/// The one real transition this widget ever makes is Splash -> HomeShell, on
/// cold start once session bootstrap resolves to authenticated - wrapped in
/// an [AnimatedSwitcher] so that hand-off is a smooth crossfade instead of an
/// abrupt cut, collapsed to an instant cut when reduce-motion is on. Resuming
/// an already-open session never re-enters this widget on `bootstrapping` at
/// all (`AuthController` only sets that status once, on first launch - see
/// its doc comment), so there is no splash flash and nothing to transition
/// on resume: HomeShell simply stays mounted the whole time, which is itself
/// the "no artificial delay, no jank" behavior asked for.
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authControllerProvider.select((s) => s.status));
    final showHome = status == AuthStatus.authenticated;

    return AnimatedSwitcher(
      duration: NokiMotion.duration(context, const Duration(milliseconds: 260)),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: showHome
          ? const HomeShell(key: ValueKey('home'))
          : const SplashScreen(key: ValueKey('splash')),
    );
  }
}
