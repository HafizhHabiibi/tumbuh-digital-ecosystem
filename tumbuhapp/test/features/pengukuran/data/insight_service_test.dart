import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/features/pengukuran/data/pengukuran_service.dart';
import 'package:tumbuhapp/shared/models/insight_model.dart';

class _Adapter implements HttpClientAdapter {
  final int statusCode;
  final Map<String, dynamic> body;

  _Adapter(this.body, {this.statusCode = 200});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_Adapter adapter) {
  return Dio(BaseOptions(baseUrl: 'http://localhost/api'))
    ..httpClientAdapter = adapter;
}

void main() {
  test('membaca status, teks, dan waktu hasil insight backend', () async {
    final service = PengukuranService(
      dio: _dio(_Adapter({
        'data': {
          'insight_status': 'completed',
          'insight_teks': 'Insight aman',
          'insight_generated_at': '2026-08-29T08:00:00.000Z',
        },
      })),
    );

    final insight = await service.getInsight(12);

    expect(insight.status, InsightStatus.completed);
    expect(insight.insightTeks, 'Insight aman');
    expect(insight.insightGeneratedAt, '2026-08-29T08:00:00.000Z');
  });

  test('membaca pending tanpa menganggapnya sebagai insight kosong', () async {
    final service = PengukuranService(
      dio: _dio(_Adapter({
        'data': {
          'insight_status': 'pending',
          'insight_teks': null,
        },
      })),
    );

    final insight = await service.getInsight(12);

    expect(insight.status, InsightStatus.pending);
    expect(insight.isInProgress, isTrue);
    expect(insight.insightTeks, isNull);
  });

  test('error jaringan diteruskan dan tidak diubah menjadi null', () async {
    final service = PengukuranService(
      dio: _dio(_Adapter({
        'success': false,
        'message': 'Server tidak tersedia',
        'data': null,
      }, statusCode: 503)),
    );

    await expectLater(service.getInsight(12), throwsA(isA<DioException>()));
  });
}
