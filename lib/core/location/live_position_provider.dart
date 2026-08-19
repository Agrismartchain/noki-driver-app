import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'location_repository.dart';

/// The device's own live position, for on-screen display only (mandate §18:
/// `DEVICE_LIVE_POSITION` is genuinely live local GPS; it is distinct from
/// [gpsPublisherControllerProvider], which throttles what's actually sent to
/// the server per [GpsPublishPolicy]). A tighter 5m filter than any publish
/// cadence is fine here - this never touches the network.
final livePositionProvider = StreamProvider.autoDispose<Position>((ref) {
  return ref.watch(locationRepositoryProvider).positionStream(distanceFilterMeters: 5);
});
