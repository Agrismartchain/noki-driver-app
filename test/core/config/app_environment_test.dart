import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/config/app_environment.dart';

void main() {
  releaseConfigTests();

  test('defaults to development with the loopback placeholder', () {
    final config = AppConfig.fromValues(
      envRaw: 'development',
      apiBaseUrlRaw: 'http://127.0.0.1:3000',
    );

    expect(config.environment, AppEnvironment.development);
    expect(config.apiBaseUrl, 'http://127.0.0.1:3000');
  });

  test('rejects an empty API base URL in staging', () {
    expect(
      () => AppConfig.fromValues(envRaw: 'staging', apiBaseUrlRaw: ''),
      throwsStateError,
    );
  });

  test('rejects an empty API base URL in production', () {
    expect(
      () => AppConfig.fromValues(envRaw: 'production', apiBaseUrlRaw: ''),
      throwsStateError,
    );
  });

  test('rejects localhost as the API base URL in staging', () {
    expect(
      () => AppConfig.fromValues(
        envRaw: 'staging',
        apiBaseUrlRaw: 'https://localhost:3000',
      ),
      throwsStateError,
    );
  });

  test('rejects 127.0.0.1 as the API base URL in production', () {
    expect(
      () => AppConfig.fromValues(
        envRaw: 'production',
        apiBaseUrlRaw: 'https://127.0.0.1:3000',
      ),
      throwsStateError,
    );
  });

  test('rejects the Android emulator loopback host in production', () {
    expect(
      () => AppConfig.fromValues(
        envRaw: 'production',
        apiBaseUrlRaw: 'https://10.0.2.2:3000',
      ),
      throwsStateError,
    );
  });

  test('rejects a plain-HTTP API base URL in staging', () {
    expect(
      () => AppConfig.fromValues(
        envRaw: 'staging',
        apiBaseUrlRaw: 'http://api.staging.noki.example.com',
      ),
      throwsStateError,
    );
  });

  test('accepts a real HTTPS API base URL in production', () {
    final config = AppConfig.fromValues(
      envRaw: 'production',
      apiBaseUrlRaw: 'https://api.noki.example.com',
    );

    expect(config.apiBaseUrl, 'https://api.noki.example.com');
  });

  test('still allows loopback and HTTP in development (safe dev mode)', () {
    final config = AppConfig.fromValues(
      envRaw: 'development',
      apiBaseUrlRaw: 'http://10.0.2.2:3000',
    );

    expect(config.apiBaseUrl, 'http://10.0.2.2:3000');
  });

  test('rejects invalid environment names', () {
    expect(
      () => AppConfig.fromValues(envRaw: 'qa', apiBaseUrlRaw: ''),
      throwsArgumentError,
    );
  });
}

void releaseConfigTests() {
  group('release configuration fails closed', () {
    test('refuses NOKI_ENV=development in a release build', () {
      expect(
        () => AppConfig.fromValues(
          envRaw: 'development',
          apiBaseUrlRaw: 'http://127.0.0.1:3000',
          isRelease: true,
        ),
        throwsStateError,
      );
    });

    test('refuses an unset NOKI_ENV in a release build', () {
      expect(
        () => AppConfig.fromValues(
          envRaw: '',
          apiBaseUrlRaw: 'http://127.0.0.1:3000',
          isRelease: true,
        ),
        throwsStateError,
      );
    });

    test('refuses production with the loopback default URL', () {
      expect(
        () => AppConfig.fromValues(
          envRaw: 'production',
          apiBaseUrlRaw: 'http://127.0.0.1:3000',
          isRelease: true,
        ),
        throwsStateError,
      );
    });

    test('accepts production with an explicit https host', () {
      final config = AppConfig.fromValues(
        envRaw: 'production',
        apiBaseUrlRaw: 'https://api.noki.example.org',
        isRelease: true,
      );
      expect(config.environment, AppEnvironment.production);
    });
  });
}
