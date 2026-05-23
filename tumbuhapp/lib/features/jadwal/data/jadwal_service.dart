import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../shared/models/jadwal_model.dart';

class JadwalService {
  final _dio = DioClient.instance;

  // ── Daftar Jadwal ─────────────────────────────

  Future<List<JadwalModel>> getJadwal() async {
    final response = await _dio.get(ApiConstants.jadwal);
    final data = response.data['data'] as List;
    return data.map((e) => JadwalModel.fromJson(e)).toList();
  }

  // ── Detail Jadwal ─────────────────────────────

  Future<JadwalModel> getDetailJadwal(int id) async {
    final response = await _dio.get(ApiConstants.detailJadwal(id));
    return JadwalModel.fromJson(response.data['data']);
  }
}
