import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../shared/models/notifikasi_model.dart.dart';

class NotifikasiService {
  final _dio = DioClient.instance;

  // ── Daftar Notifikasi ─────────────────────────

  Future<Map<String, dynamic>> getNotifikasi() async {
    final response = await _dio.get(ApiConstants.notifikasi);
    final data = response.data['data'];

    final list = (data['notifikasi'] as List)
        .map((e) => NotifikasiModel.fromJson(e))
        .toList();

    return {
      'total': data['total'] as int,
      'belumDibaca': data['belumDibaca'] as int,
      'notifikasi': list,
    };
  }

  // ── Jumlah Belum Dibaca ───────────────────────

  Future<int> getBelumDibaca() async {
    final response = await _dio.get(ApiConstants.notifikasiBelumDibaca);
    final data = response.data['data'];
    return data['belumdibaca'] as int;
  }

  // ── Tandai Dibaca ─────────────────────────────

  Future<void> bacaNotifikasi(int id) async {
    await _dio.put(ApiConstants.bacaNotifikasi(id));
  }

  // ── Tandai Semua Dibaca ───────────────────────

  Future<void> bacaSemuaNotifikasi() async {
    await _dio.put(ApiConstants.bacaSemuaNotifikasi);
  }
}
