import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../core/utils/storage_utils.dart';
import '../../../shared/models/user_model.dart';

class AuthService {
  final _dio = DioClient.instance;

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
        if (fcmToken != null) 'fcm_token': fcmToken,
      },
    );

    final data = response.data['data'];

    // Simpan token ke secure storage
    await StorageUtils.saveAccessToken(data['token']);
    await StorageUtils.saveRefreshToken(data['refresh_token']);

    // Return profil user
    return UserModel.fromJson(data['user']['profil']);
  }

  // ── Forgot Password ───────────────────────────

  Future<String> forgotPassword({required String email}) async {
    final response = await _dio.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
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

  // ── Logout ────────────────────────────────────

  Future<void> logout() async {
    await StorageUtils.clearAll();
  }
}
