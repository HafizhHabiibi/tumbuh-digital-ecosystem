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
    final body = response.data;
    if (body is! Map<String, dynamic> ||
        body['data'] is! Map<String, dynamic>) {
      throw const FormatException('Format respons rujukan tidak valid');
    }

    final data = body['data'] as Map<String, dynamic>;
    if (data['anak'] is! Map<String, dynamic> || data['rujukan'] is! List) {
      throw const FormatException('Data rujukan tidak lengkap');
    }

    final anak = AnakModel.fromJson(data['anak'] as Map<String, dynamic>);
    final rujukan = (data['rujukan'] as List).map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Item rujukan tidak valid');
      }
      return RujukanModel.fromJson(item);
    }).toList(growable: false);

    return {
      'anak': anak,
      'rujukan': rujukan,
    };
  }
}
