import 'package:geolocator/geolocator.dart';
import 'package:noki_driver_app/core/location/location_permission_state.dart';
import 'package:noki_driver_app/core/location/location_repository.dart';

/// A test double for [LocationRepository] - avoids widget tests hitting the
/// real `geolocator` platform channel (which isn't mocked and would throw
/// `MissingPluginException`).
class FakeLocationRepository implements LocationRepository {
  FakeLocationRepository({this.state = LocationPermissionState.granted});

  LocationPermissionState state;
  bool openSettingsCalled = false;
  Position? position;

  @override
  Future<LocationPermissionState> permissionState() async => state;

  @override
  Future<LocationPermissionState> requestPermission() async {
    state = LocationPermissionState.granted;
    return state;
  }

  @override
  Future<Position> currentPosition() async => position ?? _fixedPosition;

  @override
  Stream<Position> positionStream({required int distanceFilterMeters}) {
    return Stream.value(position ?? _fixedPosition);
  }

  @override
  Future<bool> openAppSettings() async {
    openSettingsCalled = true;
    return true;
  }

  static final _fixedPosition = Position(
    latitude: 33.5731,
    longitude: -7.5898,
    timestamp: DateTime(2026, 1, 1),
    accuracy: 5,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}
