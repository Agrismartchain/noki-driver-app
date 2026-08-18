import 'dart:math';

/// Generates a UUID-v4-shaped client key for idempotency-protected mutations
/// (currently: [DriverApiClient.completeMission]).
///
/// No `uuid` package dependency is added for this — the backend only needs a
/// sufficiently random, stable-per-attempt string; RFC-4122 byte layout is
/// not required. The caller must generate this once per logical attempt and
/// reuse the same value across retries of that attempt, never one value per
/// HTTP call.
String generateIdempotencyKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10
  String hex(int start, int end) => bytes.sublist(start, end).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
