import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'location_permission_state.dart';

/// The single place `Geolocator` is called from directly (mandate §7) - no
/// widget or other repository imports `package:geolocator` itself.
class LocationRepository {
  Future<LocationPermissionState> permissionState() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionState.serviceDisabled;
    }
    return _fromPermission(await Geolocator.checkPermission());
  }

  /// Requests foreground ("while in use") permission only - background
  /// permission is never requested this phase (mandate §6/§10/§11).
  Future<LocationPermissionState> requestPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionState.serviceDisabled;
    }
    return _fromPermission(await Geolocator.requestPermission());
  }

  Future<Position> currentPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// A live position stream. [distanceFilterMeters] avoids emitting on every
  /// tiny GPS jitter - see [GpsPublishPolicy] for the cadence this phase
  /// actually uses per driver work state.
  Stream<Position> positionStream({required int distanceFilterMeters}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: distanceFilterMeters),
    );
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  LocationPermissionState _fromPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionState.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionState.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionState.deniedOnce;
    }
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) => LocationRepository());

final locationPermissionStateProvider = FutureProvider.autoDispose<LocationPermissionState>(
  (ref) => ref.watch(locationRepositoryProvider).permissionState(),
);
