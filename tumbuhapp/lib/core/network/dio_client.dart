import 'package:dio/dio.dart';

import '../auth/auth_session_controller.dart';
import '../constant/app_constants.dart';
import '../constant/api_constants.dart';
import '../utils/storage_utils.dart';

class DioClient {
  DioClient._();

  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(
      dio: dio,
      getAccessToken: StorageUtils.getAccessToken,
      getRefreshToken: StorageUtils.getRefreshToken,
      saveAccessToken: StorageUtils.saveAccessToken,
      saveRefreshToken: StorageUtils.saveRefreshToken,
      clearStorage: StorageUtils.clearAll,
      refreshDioFactory: _createRefreshDio,
      onSessionExpired: AuthSessionController.instance.notifyExpired,
    ));

    return dio;
  }

  static Dio _createRefreshDio() {
    return Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }
}

class AuthInterceptor extends Interceptor {
  static const _retriedKey = 'auth_retried';

  final Dio dio;
  final Future<String?> Function() getAccessToken;
  final Future<String?> Function() getRefreshToken;
  final Future<void> Function(String token) saveAccessToken;
  final Future<void> Function(String token) saveRefreshToken;
  final Future<void> Function() clearStorage;
  final Dio Function() refreshDioFactory;
  final void Function() onSessionExpired;

  Future<_TokenPair?>? _refreshInFlight;
  bool _expirationNotified = false;

  AuthInterceptor({
    required this.dio,
    required this.getAccessToken,
    required this.getRefreshToken,
    required this.saveAccessToken,
    required this.saveRefreshToken,
    required this.clearStorage,
    required this.refreshDioFactory,
    required this.onSessionExpired,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      _expirationNotified = false;
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final options = err.requestOptions;
      final alreadyRetried = options.extra[_retriedKey] == true;

      if (!alreadyRetried) {
        final currentAccessToken = await getAccessToken();
        final sentAuthorization = options.headers['Authorization'];

        if (currentAccessToken != null &&
            currentAccessToken.isNotEmpty &&
            sentAuthorization != 'Bearer $currentAccessToken') {
          try {
            final response = await _retry(options, currentAccessToken);
            return handler.resolve(response);
          } on DioException catch (retryError) {
            return handler.reject(retryError);
          }
        }

        final tokens = await _refreshOnce();
        if (tokens != null) {
          try {
            final response = await _retry(options, tokens.accessToken);
            return handler.resolve(response);
          } on DioException catch (retryError) {
            return handler.reject(retryError);
          }
        }
      }

      await _expireSession();
    }

    handler.next(err.copyWith(error: _parseErrorMessage(err)));
  }

  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String accessToken,
  ) {
    options.headers['Authorization'] = 'Bearer $accessToken';
    options.extra[_retriedKey] = true;
    return dio.fetch(options);
  }

  Future<_TokenPair?> _refreshOnce() {
    final activeRefresh = _refreshInFlight;
    if (activeRefresh != null) return activeRefresh;

    final refresh = _performRefresh();
    _refreshInFlight = refresh;
    return refresh.whenComplete(() {
      if (identical(_refreshInFlight, refresh)) {
        _refreshInFlight = null;
      }
    });
  }

  Future<_TokenPair?> _performRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await refreshDioFactory().post(
        ApiConstants.refresh,
        data: {'refresh_token': refreshToken},
      );
      final responseData = response.data;
      if (responseData is! Map || responseData['data'] is! Map) return null;

      final data = responseData['data'] as Map;
      final accessToken = data['token'];
      final newRefreshToken = data['refresh_token'];
      if (accessToken is! String ||
          accessToken.isEmpty ||
          newRefreshToken is! String ||
          newRefreshToken.isEmpty) {
        return null;
      }

      await saveAccessToken(accessToken);
      await saveRefreshToken(newRefreshToken);
      _expirationNotified = false;
      return _TokenPair(accessToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> _expireSession() async {
    if (_expirationNotified) return;
    _expirationNotified = true;
    await clearStorage();
    onSessionExpired();
  }

  String _parseErrorMessage(DioException err) {
    final data = err.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout, periksa jaringan Anda';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server';
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        if (code == 400) return 'Permintaan tidak valid';
        if (code == 401) return 'Sesi berakhir, silakan login kembali';
        if (code == 403) return 'Akses ditolak';
        if (code == 404) return 'Data tidak ditemukan';
        if (code == 429) return 'Terlalu banyak percobaan, coba lagi nanti';
        if (code == 500) return 'Terjadi kesalahan server';
        return 'Terjadi kesalahan ($code)';
      default:
        return 'Terjadi kesalahan, coba lagi';
    }
  }
}

class _TokenPair {
  final String accessToken;

  const _TokenPair(this.accessToken);
}
