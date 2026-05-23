import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../shared/models/user_model.dart';

class ProfilService {
  final _dio = DioClient.instance;

  // ── Get Profil ────────────────────────────────

  Future<UserModel> getProfil() async {
    final response = await _dio.get(ApiConstants.profil);
    return UserModel.fromJson(response.data['data']);
  }
}
