import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constant/api_constants.dart';
import '../../../shared/models/pengukuran_model.dart';
import '../../../shared/models/anak_model.dart';
import '../../../shared/models/insight_model.dart';
import '../../../shared/models/pengukuran_response.dart';

abstract interface class InsightGateway {
  Future<InsightModel> getInsight(int pengukuranId);
}

class PengukuranService implements InsightGateway {
  final Dio _dio;

  PengukuranService({Dio? dio}) : _dio = dio ?? DioClient.instance;

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

  @override
  Future<InsightModel> getInsight(int pengukuranId) async {
    final response = await _dio.get(
      ApiConstants.insightPengukuran(pengukuranId),
    );
    final body = response.data;
    if (body is! Map || body['data'] is! Map) {
      throw const FormatException('Respons insight tidak valid');
    }
    return InsightModel.fromJson(
      Map<String, dynamic>.from(body['data'] as Map),
    );
  }
}
