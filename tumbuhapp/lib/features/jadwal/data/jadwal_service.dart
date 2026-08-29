import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../shared/models/jadwal_model.dart';

class JadwalService {
  final Dio _dio;

  JadwalService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  // ── Daftar Jadwal ─────────────────────────────

  Future<List<JadwalModel>> getJadwal() async {
    final response = await _dio.get(ApiConstants.jadwal);
    final rawData = response.data['data'];
    if (rawData is! Map) {
      throw const FormatException('Format data jadwal tidak valid');
    }
    final data = Map<String, dynamic>.from(rawData);
    final rawItems = data['items'];
    if (rawItems != null && rawItems is! List) {
      throw const FormatException('Format daftar jadwal tidak valid');
    }

    return (rawItems as List? ?? const []).map((item) {
      if (item is! Map) {
        throw const FormatException('Format item jadwal tidak valid');
      }
      return JadwalModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  // ── Detail Jadwal ─────────────────────────────

  Future<JadwalModel> getDetailJadwal(int id) async {
    final response = await _dio.get(ApiConstants.detailJadwal(id));
    final rawData = response.data['data'];
    if (rawData is! Map) {
      throw const FormatException('Format detail jadwal tidak valid');
    }
    return JadwalModel.fromJson(Map<String, dynamic>.from(rawData));
  }
}
