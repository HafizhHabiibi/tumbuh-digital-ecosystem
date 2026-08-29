import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../shared/models/pemberian_model.dart';
import '../../../shared/models/anak_model.dart';

class PemberianService {
  final Dio _dio;

  PemberianService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  // ── Riwayat Pemberian ─────────────────────────

  Future<Map<String, dynamic>> getPemberian(
    String anakId, {
    String? jenis,
  }) async {
    final response = await _dio.get(
      ApiConstants.pemberianAnak(anakId),
      queryParameters: jenis != null ? {'jenis': jenis} : null,
    );

    final rawData = response.data['data'];
    if (rawData is! Map) {
      throw const FormatException('Format data pemberian tidak valid');
    }
    final data = Map<String, dynamic>.from(rawData);

    final rawAnak = data['anak'];
    if (rawAnak is! Map) {
      throw const FormatException('Format data anak tidak valid');
    }
    final anak = AnakModel.fromJson(Map<String, dynamic>.from(rawAnak));

    final rawPemberian = data['pemberian'];
    if (rawPemberian != null && rawPemberian is! List) {
      throw const FormatException('Format daftar pemberian tidak valid');
    }
    final riwayat = (rawPemberian as List? ?? const []).map((item) {
      if (item is! Map) {
        throw const FormatException('Format item pemberian tidak valid');
      }
      return PemberianModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();

    return {
      'anak': anak,
      'filter': data['filter'] ?? 'semua',
      'riwayat': riwayat,
    };
  }
}
