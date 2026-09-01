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
        throw ArgumentError.value(raw, 'NOKI_ENV', 'Unknown environment. Use development, staging or production.');
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
    const envRaw = String.fromEnvironment('NOKI_ENV', defaultValue: 'development');
    const apiBaseUrl = String.fromEnvironment('NOKI_API_BASE_URL', defaultValue: _defaultApiBaseUrl);

    return AppConfig.fromValues(envRaw: envRaw, apiBaseUrlRaw: apiBaseUrl);
  }

  /// Same resolution as [fromDefines] but from plain values, so build-time
  /// configuration can be exercised from tests without recompiling with
  /// different `--dart-define`s.
  factory AppConfig.fromValues({
    required String envRaw,
    required String apiBaseUrlRaw,
  }) {
    final environment = AppEnvironment.fromDefine(envRaw);

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

  static const _loopbackHosts = {
    'localhost',
    '127.0.0.1',
    '10.0.2.2',
    '::1',
  };

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
