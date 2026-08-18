import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_providers.dart';
import '../features/auth/auth_state.dart';
import 'home_shell.dart';
import 'splash_screen.dart';

/// Resolves to either the blocking splash (while bootstrapping) or the
/// authenticated home shell. Unauthenticated/access-denied states never
/// reach here - `app_router.dart` redirects them away first.
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authControllerProvider.select((s) => s.status));
    if (status == AuthStatus.authenticated) {
      return const HomeShell();
    }
    return const SplashScreen();
  }
}
