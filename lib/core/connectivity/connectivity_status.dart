import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The three states the app can report about network reachability.
///
/// This is a link-layer signal only (is there an interface up). It never
/// implies backend reachability, and the app never treats a mutation as
/// having succeeded just because connectivity looks fine - a queued or
/// optimistic write is not part of this phase (see README limitations).
enum NetworkStatus { online, offline, unknown }

NetworkStatus _fromConnectivityResults(List<ConnectivityResult> results) {
  if (results.isEmpty) return NetworkStatus.unknown;
  final hasConnection = results.any((r) => r != ConnectivityResult.none);
  return hasConnection ? NetworkStatus.online : NetworkStatus.offline;
}

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

/// Streams the current network status, starting from a real initial check
/// rather than assuming "online" until the first event arrives.
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) async* {
  final connectivity = ref.watch(connectivityProvider);
  final initial = await connectivity.checkConnectivity();
  yield _fromConnectivityResults(initial);
  yield* connectivity.onConnectivityChanged.map(_fromConnectivityResults);
});
