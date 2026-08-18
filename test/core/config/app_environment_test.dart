import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/config/app_environment.dart';

void main() {
  group('AppEnvironment.fromDefine', () {
    test('parses development (including empty default)', () {
      expect(AppEnvironment.fromDefine(''), AppEnvironment.development);
      expect(AppEnvironment.fromDefine('development'), AppEnvironment.development);
      expect(AppEnvironment.fromDefine('Development'), AppEnvironment.development);
    });

    test('parses staging', () {
      expect(AppEnvironment.fromDefine('staging'), AppEnvironment.staging);
    });

    test('parses production and reports isProduction', () {
      final env = AppEnvironment.fromDefine('production');
      expect(env, AppEnvironment.production);
      expect(env.isProduction, isTrue);
      expect(AppEnvironment.development.isProduction, isFalse);
    });

    test('rejects an unknown environment name instead of silently defaulting', () {
      expect(() => AppEnvironment.fromDefine('preprod'), throwsArgumentError);
    });
  });
}
