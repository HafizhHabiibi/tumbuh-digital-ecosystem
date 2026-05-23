import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../shared/models/pemberian_model.dart';
import '../../../shared/models/anak_model.dart';

class PemberianService {
  final _dio = DioClient.instance;

  // ── Riwayat Pemberian ─────────────────────────

  Future<Map<String, dynamic>> getPemberian(
    String anakId, {
    String? jenis,
  }) async {
    final response = await _dio.get(
      ApiConstants.pemberianAnak(anakId),
      queryParameters: jenis != null ? {'jenis': jenis} : null,
    );

    final data = response.data['data'];
    final anak = AnakModel.fromJson(data['anak']);
    final riwayat = (data['riwayat'] as List)
        .map((e) => PemberianModel.fromJson(e))
        .toList();

    return {
      'anak': anak,
      'filter': data['filter'] ?? 'semua',
      'riwayat': riwayat,
    };
  }
}
