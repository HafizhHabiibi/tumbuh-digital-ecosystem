import 'package:dio/dio.dart';
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

    dio.interceptors.add(_AuthInterceptor());

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  // ── Setiap Request → Attach Token ─────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await StorageUtils.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ── Response Sukses → Lanjut ──────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  // ── Error Handler ─────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    // Token expired / tidak valid → coba refresh token sebelum logout
    if (statusCode == 401) {
      final refreshToken = await StorageUtils.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Buat instance Dio baru khusus untuk refresh agar tidak memicu interceptor auth
          final dioRefresh = Dio(BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
            receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
          ));

          final response = await dioRefresh.post(
            ApiConstants.refresh,
            data: {'refresh_token': refreshToken},
          );

          final data = response.data;
          String? newToken;
          if (data is Map) {
            if (data['data'] != null && data['data']['token'] != null) {
              newToken = data['data']['token'] as String;
            } else if (data['token'] != null) {
              newToken = data['token'] as String;
            }
          }

          if (newToken != null && newToken.isNotEmpty) {
            await StorageUtils.saveAccessToken(newToken);

            // Update header request lama
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            // Retry request lama dengan instance Dio utama
            final retryResponse = await DioClient.instance.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // Jika refresh gagal, lanjut logout
        }
      }

      // Jika refresh token null atau gagal, hapus semua data dan logout
      await StorageUtils.clearAll();
      // Navigasi ke login akan dihandle oleh go_router redirect
    }

    final message = _parseErrorMessage(err);
    final customErr = err.copyWith(
      error: message,
    );

    handler.next(customErr);
  }

  // ── Parse Pesan Error dari Backend ────────────

  String _parseErrorMessage(DioException err) {
    try {
      final data = err.response?.data;

      // Format response error dari Express kita:
      // { "message": "Email atau password salah" }
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}

    // Fallback berdasarkan jenis error
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout, periksa jaringan Anda';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server';
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        if (code == 400) return 'Permintaan tidak valid';
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
