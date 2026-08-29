import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('development menerima HTTP lokal dan menormalkan trailing slash', () {
      final config = AppConfig.resolve(
        environment: 'development',
        baseUrl: ' http://10.0.2.2:3000/api/ ',
      );

      expect(config.environment, AppEnvironment.development);
      expect(config.baseUrl, 'http://10.0.2.2:3000/api');
    });

    test('staging dan production menerima HTTPS', () {
      final staging = AppConfig.resolve(
        environment: 'staging',
        baseUrl: 'https://staging.example.com/api',
      );
      final production = AppConfig.resolve(
        environment: 'production',
        baseUrl: 'https://api.example.com/v1/api',
      );

      expect(staging.environment, AppEnvironment.staging);
      expect(production.environment, AppEnvironment.production);
    });

    test('menolak base URL kosong dengan petunjuk konfigurasi', () {
      expect(
        () => AppConfig.resolve(environment: 'development', baseUrl: ''),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('--dart-define-from-file'),
          ),
        ),
      );
    });

    test('menolak HTTP untuk staging dan production', () {
      for (final environment in ['staging', 'production']) {
        expect(
          () => AppConfig.resolve(
            environment: environment,
            baseUrl: 'http://api.example.com/api',
          ),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('wajib HTTPS'),
            ),
          ),
        );
      }
    });

    test('menolak environment, URL relatif, dan path API yang salah', () {
      expect(
        () => AppConfig.resolve(
          environment: 'qa',
          baseUrl: 'https://api.example.com/api',
        ),
        throwsStateError,
      );
      expect(
        () => AppConfig.resolve(
          environment: 'development',
          baseUrl: 'localhost:3000/api',
        ),
        throwsStateError,
      );
      expect(
        () => AppConfig.resolve(
          environment: 'production',
          baseUrl: 'https://api.example.com',
        ),
        throwsStateError,
      );
    });
  });
}
