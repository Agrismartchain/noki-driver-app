import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/features/map/map_view.dart';

void main() {
  test('production/staging never fall back to the public OSM tile servers', () {
    expect(resolveTileUrlTemplate(define: '', env: 'production'), isNull);
    expect(resolveTileUrlTemplate(define: '', env: 'staging'), isNull);
  });

  test('a configured tile server is used in every environment', () {
    const url = 'https://tiles.noki.example.com/{z}/{x}/{y}.png';
    expect(resolveTileUrlTemplate(define: url, env: 'production'), url);
    expect(resolveTileUrlTemplate(define: ' $url ', env: 'development'), url);
  });

  test('development keeps the public OSM convenience default', () {
    expect(
      resolveTileUrlTemplate(define: '', env: 'development'),
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    );
    expect(resolveTileUrlTemplate(define: '', env: ''), contains('tile.openstreetmap.org'));
  });
}
