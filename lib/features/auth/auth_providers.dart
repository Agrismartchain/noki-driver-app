import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_session_gateway.dart';
import 'auth_controller.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

/// A plain, Riverpod-independent [AuthSessionGateway] the HTTP layer depends
/// on, instead of watching `authControllerProvider.notifier` directly. See
/// [authSessionGatewayProvider].
class AuthSessionGatewayHolder implements AuthSessionGateway {
  AuthSessionGateway? _delegate;

  /// Wired once by `AuthController.build()` via `ref.read` (see
  /// `auth_controller.dart`).
  set delegate(AuthSessionGateway gateway) => _delegate = gateway;

  @override
  Future<String?> currentAccessToken() => _delegate?.currentAccessToken() ?? Future.value();

  @override
  Future<String?> refreshAccessToken() => _delegate?.refreshAccessToken() ?? Future.value();

  @override
  Future<void> onSessionExpired() => _delegate?.onSessionExpired() ?? Future.value();
}

/// Exposes an [AuthSessionGateway] to the HTTP layer without `core/api`
/// depending on `features/auth` types beyond this one interface, and -
/// critically - without `driverApiDioProvider` ever watching
/// `authControllerProvider` as a Riverpod dependency.
///
/// `driverApiDioProvider` (via this provider) is watched by
/// `driverApiClientProvider`, which `AuthController` itself reads (lazily,
/// from its own async methods - see `auth_controller.dart`) to make its own
/// API calls. If this provider watched `authControllerProvider.notifier`
/// directly, that would make `driverApiClientProvider` transitively depend
/// on `authControllerProvider` in Riverpod's own dependency graph - and
/// Riverpod blocks any read of a provider that transitively depends on a
/// Notifier while that Notifier's own async method (e.g. `login()`) is still
/// running, *even if the depending provider is already fully built and
/// cached* - a real, reproducible silent deadlock (never an exception, the
/// isolate just sits idle awaiting a Future that never resolves), confirmed
/// on real Android by instrumenting every step of the chain: pre-warming
/// `driverApiClientProvider` at the widget level built it successfully and
/// cached it, yet the exact same `ref.read(driverApiClientProvider)` called
/// from inside `AuthController.login()` still hung indefinitely, while an
/// unrelated `ref.read()` call in the same method, same line position,
/// returned instantly. See DRIVER-APP-01R4.
///
/// [AuthSessionGatewayHolder] has a stable identity with zero Riverpod
/// dependencies of its own, so watching it never creates that edge.
/// `AuthController.build()` wires itself into the holder via `ref.read`
/// (not `ref.watch`) - a one-time, untracked pointer assignment.
final authSessionGatewayProvider = Provider<AuthSessionGatewayHolder>((ref) => AuthSessionGatewayHolder());
