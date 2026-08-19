/// Foreground location permission/service state, mapped from `geolocator`'s
/// own [LocationPermission]/[isLocationServiceEnabled] into a small closed
/// set the UI can exhaustively switch on (mandate DRIVER-APP-03 §6).
enum LocationPermissionState {
  /// Permission granted (`whileInUse` or `always`) and the device's location
  /// service is on - GPS reads/publishing can proceed.
  granted,

  /// Permission not yet granted, or denied once - the app may ask again.
  deniedOnce,

  /// Permission permanently denied ("don't ask again" / iOS "Never") - the
  /// app must not re-prompt; only an "open settings" action is offered.
  deniedForever,

  /// Permission is granted but the device's location service itself
  /// (Location/GPS toggle) is off - no permission prompt can fix this.
  serviceDisabled,
}
