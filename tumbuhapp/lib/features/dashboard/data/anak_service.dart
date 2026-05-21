import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../shared/models/anak_model.dart';

class AnakService {
  final _dio = DioClient.instance;

  // ── Daftar Anak ───────────────────────────────

  Future<List<AnakModel>> getDaftarAnak() async {
    final response = await _dio.get(ApiConstants.daftarAnak);
    final data = response.data['data'] as List;
    return data.map((e) => AnakModel.fromJson(e)).toList();
  }

  // ── Detail Anak ───────────────────────────────

  Future<AnakModel> getDetailAnak(String anakId) async {
    final response = await _dio.get(ApiConstants.detailAnak(anakId));
    return AnakModel.fromJson(response.data['data']);
  }
}
