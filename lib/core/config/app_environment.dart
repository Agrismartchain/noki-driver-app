import 'package:flutter/foundation.dart' show kReleaseMode;

/// The three environments the Driver App can be built for.
///
/// Selected at build time via `--dart-define=NOKI_ENV=development|staging|production`
/// (see `AppEnvironment.fromDefine`). Never hardcode a base URL, token or secret
/// here - only structural configuration.
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment fromDefine(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'staging':
        return AppEnvironment.staging;
      case 'production':
        return AppEnvironment.production;
      case 'development':
      case '':
        return AppEnvironment.development;
      default:
        throw ArgumentError.value(
          raw,
          'NOKI_ENV',
          'Unknown environment. Use development, staging or production.',
        );
    }
  }

  String get label {
    switch (this) {
      case AppEnvironment.development:
        return 'Development';
      case AppEnvironment.staging:
        return 'Staging';
      case AppEnvironment.production:
        return 'Production';
    }
  }

  bool get isProduction => this == AppEnvironment.production;
}

/// Build-time application configuration.
///
/// All values come from `--dart-define` entries (see `README.md`), never from
/// checked-in secrets. `apiBaseUrl` carries no embedded credentials.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  factory AppConfig.fromDefines() {
    const envRaw = String.fromEnvironment(
      'NOKI_ENV',
      defaultValue: 'development',
    );
    const apiBaseUrl = String.fromEnvironment(
      'NOKI_API_BASE_URL',
      defaultValue: _defaultApiBaseUrl,
    );

    // `NOKI_ENV` silently defaults to "development" when no --dart-define is
    // passed at all, which would otherwise let a `flutter build apk --release`
    // run with zero dart-defines compile and ship pointed at a loopback host
    // (the staging/production guard below never runs, because it never sees
    // "staging"/"production"). Release builds must always declare NOKI_ENV
    // explicitly - see README.md "Production builds".
    const hasExplicitEnv = bool.hasEnvironment('NOKI_ENV');
    if (kReleaseMode && !hasExplicitEnv) {
      throw StateError(
        'NOKI_ENV was not passed via --dart-define (or '
        '--dart-define-from-file) for this release build. Release builds '
        'must always declare NOKI_ENV explicitly - see README.md '
        '"Production builds" - otherwise the build silently defaults to '
        '"development" and may ship pointed at a loopback API host.',
      );
    }

    return AppConfig.fromValues(
      envRaw: envRaw,
      apiBaseUrlRaw: apiBaseUrl,
      isRelease: kReleaseMode,
    );
  }

  /// Same resolution as [fromDefines] but from plain values, so build-time
  /// configuration can be exercised from tests without recompiling with
  /// different `--dart-define`s.
  factory AppConfig.fromValues({
    required String envRaw,
    required String apiBaseUrlRaw,
    bool isRelease = false,
  }) {
    final environment = AppEnvironment.fromDefine(envRaw);

    // Release builds never run against development defaults (loopback, HTTP).
    if (isRelease && environment == AppEnvironment.development) {
      throw StateError(
        'Release builds must be built with NOKI_ENV=staging or production '
        '(got development).',
      );
    }

    _guardAgainstUnsafeBaseUrl(apiBaseUrlRaw, environment);

    return AppConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrlRaw,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    );
  }

  // Placeholder pointing at a loopback address so a misconfigured build fails
  // fast against a real environment instead of silently talking to nothing.
  // Every real environment must set NOKI_API_BASE_URL explicitly at build time.
  static const String _defaultApiBaseUrl = 'http://127.0.0.1:3000';

  static const _loopbackHosts = {'localhost', '127.0.0.1', '10.0.2.2', '::1'};

  /// For staging/production, a field/release build must never be able to
  /// point at a loopback host, and must use HTTPS. development remains the
  /// only explicit "safe dev mode" allowed to use loopback + HTTP.
  static void _guardAgainstUnsafeBaseUrl(
    String apiBaseUrl,
    AppEnvironment environment,
  ) {
    if (environment != AppEnvironment.staging &&
        environment != AppEnvironment.production) {
      return;
    }

    final uri = Uri.tryParse(apiBaseUrl);
    if (uri == null || uri.host.isEmpty) {
      throw StateError(
        'NOKI_API_BASE_URL ("$apiBaseUrl") is not a valid absolute URL for '
        '${environment.label}.',
      );
    }

    if (_loopbackHosts.contains(uri.host.toLowerCase())) {
      throw StateError(
        'NOKI_API_BASE_URL must not point to a loopback host '
        '("${uri.host}") in ${environment.label}. Configure a real Pilot '
        'or production API host.',
      );
    }

    if (uri.scheme != 'https') {
      throw StateError(
        'NOKI_API_BASE_URL must use HTTPS in ${environment.label} '
        '(got scheme "${uri.scheme}").',
      );
    }
  }
}
