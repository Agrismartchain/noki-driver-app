import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/root_gate.dart';
import '../../features/auth/access_denied_screen.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/auth_state.dart';
import '../../features/auth/login_screen.dart';

/// Bridges Riverpod's [authControllerProvider] to go_router's
/// `refreshListenable`, so a status change (e.g. session expiring mid-use)
/// re-evaluates [redirect] without any manual navigation calls scattered
/// through the app.
class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.status != next.status) notifyListeners();
    });
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthRouterRefresh(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final path = state.matchedLocation;

      switch (authState.status) {
        case AuthStatus.bootstrapping:
          return path == '/' ? null : '/';
        case AuthStatus.unauthenticated:
        case AuthStatus.authenticating:
          return path == '/login' ? null : '/login';
        case AuthStatus.accessDenied:
          return path == '/access-denied' ? null : '/access-denied';
        case AuthStatus.authenticated:
          return (path == '/login' || path == '/access-denied') ? '/' : null;
      }
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const RootGate()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/access-denied', builder: (context, state) => const AccessDeniedScreen()),
    ],
  );
});
