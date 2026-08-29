import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/core/constant/api_constants.dart';
import 'package:tumbuhapp/features/auth/data/auth_service.dart';

class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;

    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'message': 'Login berhasil',
        'data': {
          'token': 'access-token',
          'refresh_token': 'refresh-token',
          'user': {
            'id': 'user-id',
            'email': 'orangtua@example.com',
            'role': 'orang_tua',
            'profil': {
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
          },
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('endpoint fase 1 sesuai dengan route backend', () {
    expect(ApiConstants.login, '/auth/login');
    expect(ApiConstants.profil, '/orang-tua/profile');
    expect(
      ApiConstants.updateFcmToken,
      '/orang-tua/update-fcm-token',
    );
  });

  group('AuthService.login', () {
    test('mengirim endpoint dan payload mobile serta menyimpan token',
        () async {
      final adapter = _RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'))
        ..httpClientAdapter = adapter;
      String? savedAccessToken;
      String? savedRefreshToken;
      final service = AuthService(
        dio: dio,
        saveAccessToken: (token) async => savedAccessToken = token,
        saveRefreshToken: (token) async => savedRefreshToken = token,
      );

      final user = await service.login(
        email: 'orangtua@example.com',
        password: 'rahasia',
        fcmToken: 'fcm-token',
      );

      expect(adapter.request?.method, 'POST');
      expect(adapter.request?.path, ApiConstants.login);
      expect(adapter.request?.data, {
        'email': 'orangtua@example.com',
        'password': 'rahasia',
        'platform': 'mobile',
        'fcm_token': 'fcm-token',
      });
      expect(savedAccessToken, 'access-token');
      expect(savedRefreshToken, 'refresh-token');
      expect(user.namaLengkap, 'Orang Tua');
    });

    test('tidak mengirim fcm_token ketika token tidak tersedia', () async {
      final adapter = _RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'))
        ..httpClientAdapter = adapter;
      final service = AuthService(
        dio: dio,
        saveAccessToken: (_) async {},
        saveRefreshToken: (_) async {},
      );

      await service.login(
        email: 'orangtua@example.com',
        password: 'rahasia',
      );

      expect(adapter.request?.data, {
        'email': 'orangtua@example.com',
        'password': 'rahasia',
        'platform': 'mobile',
      });
    });
  });

  test('forgot password mengirim payload platform mobile', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'))
      ..httpClientAdapter = adapter;
    final service = AuthService(
      dio: dio,
      saveAccessToken: (_) async {},
      saveRefreshToken: (_) async {},
    );

    await service.forgotPassword(email: 'orangtua@example.com');

    expect(adapter.request?.method, 'POST');
    expect(adapter.request?.path, ApiConstants.forgotPassword);
    expect(adapter.request?.data, {
      'email': 'orangtua@example.com',
      'platform': 'mobile',
    });
  });
}
