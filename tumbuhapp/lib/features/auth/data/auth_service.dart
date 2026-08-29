import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../core/utils/storage_utils.dart';
import '../../../shared/models/user_model.dart';

class AuthService {
  final Dio _dio;
  final Future<void> Function(String token) _saveAccessToken;
  final Future<void> Function(String token) _saveRefreshToken;
  final Future<void> Function() _clearStorage;

  AuthService({
    Dio? dio,
    Future<void> Function(String token)? saveAccessToken,
    Future<void> Function(String token)? saveRefreshToken,
    Future<void> Function()? clearStorage,
  })  : _dio = dio ?? DioClient.instance,
        _saveAccessToken = saveAccessToken ?? StorageUtils.saveAccessToken,
        _saveRefreshToken = saveRefreshToken ?? StorageUtils.saveRefreshToken,
        _clearStorage = clearStorage ?? StorageUtils.clearAll;

  // ── Login ─────────────────────────────────────

  Future<UserModel> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
        'platform': 'mobile',
        if (fcmToken != null) 'fcm_token': fcmToken,
      },
    );

    final data = response.data['data'];

    // Simpan token ke secure storage
    await _saveAccessToken(data['token']);
    await _saveRefreshToken(data['refresh_token']);

    // Return profil user
    return UserModel.fromJson(data['user']['profil']);
  }

  // ── Forgot Password ───────────────────────────

  Future<String> forgotPassword({required String email}) async {
    final response = await _dio.post(
      ApiConstants.forgotPassword,
      data: {
        'email': email,
        'platform': 'mobile',
      },
    );
    return response.data['message'];
  }

  // ── Change Password ───────────────────────────

  Future<String> changePassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    final response = await _dio.put(
      ApiConstants.changePassword,
      data: {
        'password_lama': passwordLama,
        'password_baru': passwordBaru,
      },
    );
    return response.data['message'];
  }

  // ── Restore Session ───────────────────────────

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get(ApiConstants.profil);
    final data = response.data['data'];
    if (data is! Map) {
      throw const FormatException('Format profil pengguna tidak valid');
    }
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  // ── Logout ────────────────────────────────────

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } finally {
      await _clearStorage();
    }
  }
}
