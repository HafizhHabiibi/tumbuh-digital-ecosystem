import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../shared/models/notifikasi_model.dart';
import '../../../shared/models/notifikasi_response.dart';

class NotifikasiService {
  final Dio _dio;

  NotifikasiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  // ── Daftar Notifikasi ─────────────────────────

  Future<NotifikasiResponse> getNotifikasi() async {
    final response = await _dio.get(ApiConstants.notifikasi);
    final rawData = response.data['data'];
    if (rawData is! Map) {
      throw const FormatException('Format data notifikasi tidak valid');
    }
    final data = Map<String, dynamic>.from(rawData);

    final rawNotifikasi = data['notifikasi'];
    if (rawNotifikasi != null && rawNotifikasi is! List) {
      throw const FormatException('Format daftar notifikasi tidak valid');
    }
    final list = (rawNotifikasi as List? ?? const []).map((item) {
      if (item is! Map) {
        throw const FormatException('Format item notifikasi tidak valid');
      }
      return NotifikasiModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();

    return NotifikasiResponse(
      total: _asInt(data['total']),
      belumDibaca: _asInt(data['belum_dibaca']),
      notifikasi: list,
    );
  }

  // ── Jumlah Belum Dibaca ───────────────────────

  Future<int> getBelumDibaca() async {
    final response = await _dio.get(ApiConstants.notifikasiBelumDibaca);
    final rawData = response.data['data'];
    if (rawData is! Map) {
      throw const FormatException('Format jumlah notifikasi tidak valid');
    }
    return _asInt(rawData['belum_dibaca']);
  }

  // ── Tandai Dibaca ─────────────────────────────

  Future<void> bacaNotifikasi(int id) async {
    await _dio.put(ApiConstants.bacaNotifikasi(id));
  }

  // ── Tandai Semua Dibaca ───────────────────────

  Future<void> bacaSemuaNotifikasi() async {
    await _dio.put(ApiConstants.bacaSemuaNotifikasi);
  }

  int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
