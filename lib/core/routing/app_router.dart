import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/root_gate.dart';
import '../../features/auth/access_denied_screen.dart';
import '../../features/auth/auth_state.dart';
import '../../features/auth/login_screen.dart';

/// A plain, Riverpod-independent [Listenable] go_router's `redirect`
/// re-evaluates against. Deliberately *not* constructed by calling
/// `ref.listen`/`ref.watch(authControllerProvider...)` from within this (or
/// any other) provider's build - see [routerRefreshListenableProvider].
///
/// [status] mirrors [AuthState.status] as a plain field, kept up to date by
/// `AuthController`'s own `listenSelf` (see `auth_controller.dart`).
/// [redirect] below reads [status] directly instead of
/// `ref.read(authControllerProvider)`. go_router calls `redirect`
/// synchronously the first time its internal `Router` widget mounts - nested
/// inside the same widget-build pass that is still resolving
/// `appRouterProvider`/`authControllerProvider` via `NokiDriverApp.build()`.
/// Reading a Riverpod provider from there trips Riverpod's re-entrant-read
/// guard (`CircularDependencyError`), even though the provider itself isn't
/// actually cyclic - reproduced deterministically both on real Android and
/// in a local widget-test harness pumping the real, non-overridden provider
/// graph (see DRIVER-APP-01R2). A plain field read has no such restriction.
class RouterRefreshListenable extends ChangeNotifier {
  AuthStatus status = AuthStatus.bootstrapping;

  void refresh() => notifyListeners();
}

final routerRefreshListenableProvider = Provider<RouterRefreshListenable>((ref) => RouterRefreshListenable());

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final status = refreshListenable.status;
      final path = state.matchedLocation;

      switch (status) {
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
