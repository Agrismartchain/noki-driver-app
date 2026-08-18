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
    final environment = AppEnvironment.fromDefine(envRaw);

    const apiBaseUrl = String.fromEnvironment('NOKI_API_BASE_URL', defaultValue: _defaultApiBaseUrl);

    return AppConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    );
  }

  // Placeholder pointing at a loopback address so a misconfigured build fails
  // fast against a real environment instead of silently talking to nothing.
  // Every real environment must set NOKI_API_BASE_URL explicitly at build time.
  static const String _defaultApiBaseUrl = 'http://127.0.0.1:3000';
}
