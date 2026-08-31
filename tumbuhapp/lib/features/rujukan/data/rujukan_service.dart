import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../shared/models/rujukan_model.dart';
import '../../../shared/models/anak_model.dart';

class RujukanService {
  final Dio _dio;

  RujukanService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  // ── Riwayat Rujukan ───────────────────────────

  Future<Map<String, dynamic>> getRujukan(String anakId) async {
    final response = await _dio.get(ApiConstants.rujukanAnak(anakId));
    final data = response.data['data'];

    final anak = AnakModel.fromJson(data['anak']);
    final rujukan =
        (data['rujukan'] as List).map((e) => RujukanModel.fromJson(e)).toList();

    return {
      'anak': anak,
      'rujukan': rujukan,
    };
  }
}
