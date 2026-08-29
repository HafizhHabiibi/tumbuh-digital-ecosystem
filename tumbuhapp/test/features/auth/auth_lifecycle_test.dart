import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/core/auth/auth_session_controller.dart';
import 'package:tumbuhapp/core/network/dio_client.dart';
import 'package:tumbuhapp/features/auth/data/auth_service.dart';
import 'package:tumbuhapp/features/auth/providers/auth_provider.dart';

class _AsyncAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) responder;

  _AsyncAdapter(this.responder);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Map<String, dynamic> data, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, dynamic> _profileResponse() => {
      'data': {
        'id': 'profile-id',
        'user_id': 'user-id',
        'email': 'orangtua@example.com',
        'nama_lengkap': 'Orang Tua',
        'no_hp': '081234567890',
        'alamat': 'Alamat',
        'nik': '1234567890123456',
        'created_at': '2026-08-29T00:00:00.000Z',
        'updated_at': '2026-08-29T00:00:00.000Z',
      },
    };

void main() {
  group('AuthInterceptor', () {
    test('satu refresh untuk request 401 bersamaan dan menyimpan token rotasi',
        () async {
      var accessToken = 'access-lama';
      var refreshToken = 'refresh-lama';
      var refreshCalls = 0;

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.httpClientAdapter = _AsyncAdapter((options) async {
        if (options.headers['Authorization'] == 'Bearer access-baru') {
          return _jsonBody({'data': 'ok'});
        }
        return _jsonBody(
          {'message': 'Token kedaluwarsa'},
          statusCode: 401,
        );
      });

      Dio refreshDioFactory() {
        final refreshDio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
        refreshDio.httpClientAdapter = _AsyncAdapter((options) async {
          refreshCalls++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          expect(options.data, {'refresh_token': 'refresh-lama'});
          return _jsonBody({
            'data': {
              'token': 'access-baru',
              'refresh_token': 'refresh-baru',
            },
          });
        });
        return refreshDio;
      }

      dio.interceptors.add(AuthInterceptor(
        dio: dio,
        getAccessToken: () async => accessToken,
        getRefreshToken: () async => refreshToken,
        saveAccessToken: (token) async => accessToken = token,
        saveRefreshToken: (token) async => refreshToken = token,
        clearStorage: () async {},
        refreshDioFactory: refreshDioFactory,
        onSessionExpired: () {},
      ));

      final responses = await Future.wait([
        dio.get('/protected'),
        dio.get('/protected'),
      ]);

      expect(
          responses.map((response) => response.statusCode), everyElement(200));
      expect(refreshCalls, 1);
      expect(accessToken, 'access-baru');
      expect(refreshToken, 'refresh-baru');
    });

    test('refresh gagal membersihkan storage dan memberi event sekali',
        () async {
      var clearCalls = 0;
      var expiredEvents = 0;
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.httpClientAdapter = _AsyncAdapter(
        (_) async => _jsonBody({'message': 'Unauthorized'}, statusCode: 401),
      );

      Dio refreshDioFactory() {
        final refreshDio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
        refreshDio.httpClientAdapter = _AsyncAdapter(
          (_) async => _jsonBody(
            {'message': 'Refresh token tidak valid'},
            statusCode: 401,
          ),
        );
        return refreshDio;
      }

      dio.interceptors.add(AuthInterceptor(
        dio: dio,
        getAccessToken: () async => 'access-lama',
        getRefreshToken: () async => 'refresh-lama',
        saveAccessToken: (_) async {},
        saveRefreshToken: (_) async {},
        clearStorage: () async => clearCalls++,
        refreshDioFactory: refreshDioFactory,
        onSessionExpired: () => expiredEvents++,
      ));

      await Future.wait([
        expectLater(dio.get('/satu'), throwsA(isA<DioException>())),
        expectLater(dio.get('/dua'), throwsA(isA<DioException>())),
      ]);

      expect(clearCalls, 1);
      expect(expiredEvents, 1);
    });
  });

  group('AuthService', () {
    test('logout memanggil backend dan selalu membersihkan storage', () async {
      String? requestedPath;
      var cleared = false;
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.httpClientAdapter = _AsyncAdapter((options) async {
        requestedPath = options.path;
        return _jsonBody({'message': 'Server error'}, statusCode: 500);
      });
      final service = AuthService(
        dio: dio,
        saveAccessToken: (_) async {},
        saveRefreshToken: (_) async {},
        clearStorage: () async => cleared = true,
      );

      await expectLater(service.logout(), throwsA(isA<DioException>()));

      expect(requestedPath, '/auth/logout');
      expect(cleared, isTrue);
    });
  });

  group('AuthNotifier', () {
    test('memulihkan profil ketika token tersimpan', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.httpClientAdapter = _AsyncAdapter(
        (_) async => _jsonBody(_profileResponse()),
      );
      final service = AuthService(
        dio: dio,
        saveAccessToken: (_) async {},
        saveRefreshToken: (_) async {},
        clearStorage: () async {},
      );
      final notifier = AuthNotifier(
        service,
        hasStoredSession: () async => true,
        getFcmToken: () async => null,
        sessionController: AuthSessionController(),
      );

      await notifier.restoreSession();

      expect(notifier.state.status, AuthStatus.authenticated);
      expect(notifier.state.user?.namaLengkap, 'Orang Tua');
      notifier.dispose();
    });

    test('event sesi kedaluwarsa mengubah state menjadi unauthenticated',
        () async {
      final controller = AuthSessionController();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.httpClientAdapter = _AsyncAdapter(
        (_) async => _jsonBody(_profileResponse()),
      );
      final notifier = AuthNotifier(
        AuthService(
          dio: dio,
          saveAccessToken: (_) async {},
          saveRefreshToken: (_) async {},
          clearStorage: () async {},
        ),
        hasStoredSession: () async => true,
        getFcmToken: () async => null,
        sessionController: controller,
      );
      await notifier.restoreSession();

      controller.notifyExpired();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.user, isNull);
      notifier.dispose();
    });
  });
}
