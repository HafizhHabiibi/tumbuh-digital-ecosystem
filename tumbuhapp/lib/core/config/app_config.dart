enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment parse(String value) {
    return switch (value.trim().toLowerCase()) {
      'development' => AppEnvironment.development,
      'staging' => AppEnvironment.staging,
      'production' => AppEnvironment.production,
      _ => throw StateError(
          'APP_ENV harus bernilai development, staging, atau production.',
        ),
    };
  }
}

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.baseUrl,
  });

  final AppEnvironment environment;
  final String baseUrl;

  factory AppConfig.resolve({
    required String environment,
    required String baseUrl,
  }) {
    final parsedEnvironment = AppEnvironment.parse(environment);
    final normalizedBaseUrl = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');

    if (normalizedBaseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL belum dikonfigurasi. Jalankan Flutter dengan '
        '--dart-define-from-file=<file-konfigurasi>.',
      );
    }

    final uri = Uri.tryParse(normalizedBaseUrl);
    final usesSupportedScheme = uri?.scheme == 'http' || uri?.scheme == 'https';
    if (uri == null ||
        !uri.isAbsolute ||
        !usesSupportedScheme ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw StateError(
        'API_BASE_URL harus berupa URL absolut HTTP/HTTPS tanpa query atau fragment.',
      );
    }

    if (!uri.path.endsWith('/api')) {
      throw StateError('API_BASE_URL harus berakhir dengan /api.');
    }

    if (parsedEnvironment != AppEnvironment.development &&
        uri.scheme != 'https') {
      throw StateError('API_BASE_URL untuk staging/production wajib HTTPS.');
    }

    return AppConfig(
      environment: parsedEnvironment,
      baseUrl: normalizedBaseUrl,
    );
  }
}
