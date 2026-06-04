import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../shared/models/pengukuran_model.dart';
import '../../../shared/models/anak_model.dart';
import '../../../shared/models/insight_model.dart';
import '../../../shared/models/pengukuran_response.dart';

class PengukuranService {
  final _dio = DioClient.instance;

  // ── Riwayat Pengukuran ────────────────────────

  Future<PengukuranResponse> getPengukuran(String anakId) async {
    final response = await _dio.get(ApiConstants.pengukuranAnak(anakId));
    final data = response.data['data'];

    final anak = AnakModel.fromJson(data['anak']);
    final riwayat = (data['riwayat'] as List)
        .map((e) => PengukuranModel.fromJson(e))
        .toList();

    return PengukuranResponse(anak: anak, riwayat: riwayat);
  }

  // ── Insight Pengukuran ────────────────────────

  Future<InsightModel?> getInsight(int pengukuranId) async {
    try {
      final response = await _dio.get(
        ApiConstants.insightPengukuran(pengukuranId),
      );
      final data = response.data['data'];
      if (data == null) return null;
      return InsightModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
