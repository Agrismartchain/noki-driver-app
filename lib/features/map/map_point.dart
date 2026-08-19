/// A generic map point. Business features hand this in - `flutter_map`'s
/// `LatLng` type never leaks past `map_view.dart`/`map_markers.dart`
/// (mandate §5).
class MapPoint {
  const MapPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}
