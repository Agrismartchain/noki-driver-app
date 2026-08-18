import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_session_gateway.dart';
import 'auth_controller.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Exposes `AuthController` (which implements [AuthSessionGateway]) to the
/// HTTP layer without `core/api` depending on `features/auth` types beyond
/// this one interface. See `core/api/api_providers.dart`.
final authSessionGatewayProvider = Provider<AuthSessionGateway>((ref) {
  return ref.watch(authControllerProvider.notifier);
});
