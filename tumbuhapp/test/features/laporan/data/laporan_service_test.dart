import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/features/laporan/data/laporan_service.dart';

class _ResponseAdapter implements HttpClientAdapter {
  final int statusCode;
  final List<int> bytes;
  final Map<String, List<String>> headers;
  RequestOptions? request;

  _ResponseAdapter({
    required this.statusCode,
    required this.bytes,
    required this.headers,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromBytes(
      bytes,
      statusCode,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_ResponseAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'))
    ..httpClientAdapter = adapter;
}

void main() {
  const anakId = '018f0000-0000-7000-8000-000000000001';
  final pdfBytes = utf8.encode('%PDF-1.4\ncontoh laporan');

  test('mengunduh PDF, membaca nama file, lalu membuka dialog simpan',
      () async {
    final adapter = _ResponseAdapter(
      statusCode: 200,
      bytes: pdfBytes,
      headers: {
        Headers.contentTypeHeader: ['application/pdf'],
        'content-disposition': [
          'attachment; filename="laporan-ringkasan-budi.pdf"',
        ],
      },
    );
    String? savedName;
    Uint8List? savedBytes;
    final service = LaporanService(
      dio: _dio(adapter),
      savePdf: (name, bytes) async {
        savedName = name;
        savedBytes = bytes;
        return '/downloads/$name';
      },
    );

    final result = await service.downloadLaporanAnak(anakId);

    expect(adapter.request?.path, '/laporan/anak/$anakId');
    expect(adapter.request?.responseType, ResponseType.bytes);
    expect(adapter.request?.headers['Accept'], 'application/pdf');
    expect(savedName, 'laporan-ringkasan-budi.pdf');
    expect(savedBytes, pdfBytes);
    expect(result.fileName, 'laporan-ringkasan-budi.pdf');
  });

  test('memakai nama aman ketika filename tidak dikirim backend', () async {
    final adapter = _ResponseAdapter(
      statusCode: 200,
      bytes: pdfBytes,
      headers: {
        Headers.contentTypeHeader: ['application/pdf'],
      },
    );
    final service = LaporanService(
      dio: _dio(adapter),
      savePdf: (name, _) async => '/downloads/$name',
    );

    final result = await service.downloadLaporanAnak(anakId);

    expect(result.fileName, 'laporan-pertumbuhan.pdf');
  });

  test('meneruskan pesan JSON backend walaupun response diminta sebagai bytes',
      () async {
    final adapter = _ResponseAdapter(
      statusCode: 422,
      bytes: utf8.encode(jsonEncode({
        'success': false,
        'message': 'Anak belum memiliki pengukuran',
        'data': null,
      })),
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
    final service = LaporanService(
      dio: _dio(adapter),
      savePdf: (_, __) async => fail('Dialog simpan tidak boleh dipanggil'),
    );

    await expectLater(
      service.downloadLaporanAnak(anakId),
      throwsA(
        isA<LaporanDownloadException>()
            .having((error) => error.statusCode, 'statusCode', 422)
            .having(
              (error) => error.message,
              'message',
              'Anak belum memiliki pengukuran',
            ),
      ),
    );
  });

  test('menolak body sukses yang bukan PDF', () async {
    final adapter = _ResponseAdapter(
      statusCode: 200,
      bytes: utf8.encode('<html>bukan pdf</html>'),
      headers: {
        Headers.contentTypeHeader: ['text/html'],
      },
    );
    final service = LaporanService(
      dio: _dio(adapter),
      savePdf: (_, __) async => fail('Dialog simpan tidak boleh dipanggil'),
    );

    await expectLater(
      service.downloadLaporanAnak(anakId),
      throwsA(
        isA<LaporanDownloadException>().having(
          (error) => error.message,
          'message',
          contains('bukan file PDF'),
        ),
      ),
    );
  });

  test('membedakan pembatalan dialog simpan dari kegagalan download', () async {
    final adapter = _ResponseAdapter(
      statusCode: 200,
      bytes: pdfBytes,
      headers: {
        Headers.contentTypeHeader: ['application/pdf'],
      },
    );
    final service = LaporanService(
      dio: _dio(adapter),
      savePdf: (_, __) async => null,
    );

    await expectLater(
      service.downloadLaporanAnak(anakId),
      throwsA(isA<LaporanDownloadCancelled>()),
    );
  });
}
