import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/features/jadwal/data/jadwal_service.dart';
import 'package:tumbuhapp/features/notifikasi/data/notifikasi_service.dart';
import 'package:tumbuhapp/features/pemberian/data/pemberian_service.dart';

class _JsonAdapter implements HttpClientAdapter {
  final Map<String, dynamic> Function(RequestOptions options) responder;

  _JsonAdapter(this.responder);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(responder(options)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(Map<String, dynamic> Function(RequestOptions options) responder) {
  return Dio(BaseOptions(baseUrl: 'http://localhost/api'))
    ..httpClientAdapter = _JsonAdapter(responder);
}

Map<String, dynamic> _anak() => {
      'id': '01900000-0000-7000-8000-000000000001',
      'nama': 'Budi',
      'jenis_kelamin': 'L',
      'tanggal_lahir': '2024-01-01',
      'nik': '1234567890123456',
      'created_at': '2026-08-29T00:00:00.000Z',
    };

void main() {
  group('PemberianService', () {
    test('membaca key pemberian dari respons backend', () async {
      final service = PemberianService(
        dio: _dio((_) => {
              'data': {
                'anak': _anak(),
                'filter': 'semua',
                'pemberian': [
                  {
                    'id': 1,
                    'jenis': 'obat_cacing',
                    'dosis': '1 tablet',
                    'tanggal_pemberian': '2026-08-29',
                    'keterangan': null,
                    'created_at': '2026-08-29T00:00:00.000Z',
                    'dicatat_oleh': 'Kader Satu',
                  },
                ],
              },
            }),
      );

      final result = await service.getPemberian(_anak()['id'] as String);

      expect(result['filter'], 'semua');
      expect(result['riwayat'], hasLength(1));
    });

    test('menghasilkan daftar kosong ketika pemberian kosong', () async {
      final service = PemberianService(
        dio: _dio((_) => {
              'data': {'anak': _anak(), 'pemberian': []},
            }),
      );

      final result = await service.getPemberian(_anak()['id'] as String);

      expect(result['riwayat'], isEmpty);
    });
  });

  group('JadwalService', () {
    test('membaca data.items dari respons pagination backend', () async {
      final service = JadwalService(
        dio: _dio((_) => {
              'data': {
                'items': [
                  {
                    'id': 1,
                    'tanggal': '2026-09-01',
                    'waktu_mulai': '08:00:00',
                    'waktu_selesai': '10:00:00',
                    'lokasi': 'Posyandu Melati',
                    'keterangan': null,
                    'created_at': '2026-08-29T00:00:00.000Z',
                    'dibuat_oleh': 'Kader Satu',
                  },
                ],
                'pagination': {'page': 1, 'total': 1},
              },
            }),
      );

      final result = await service.getJadwal();

      expect(result, hasLength(1));
      expect(result.single.lokasi, 'Posyandu Melati');
    });

    test('menghasilkan daftar kosong ketika items tidak tersedia', () async {
      final service = JadwalService(
        dio: _dio((_) => {
              'data': {'items': []},
            }),
      );

      expect(await service.getJadwal(), isEmpty);
    });
  });

  group('NotifikasiService', () {
    test('membaca belum_dibaca dan daftar notifikasi', () async {
      final service = NotifikasiService(
        dio: _dio((_) => {
              'data': {
                'total': 2.0,
                'belum_dibaca': 1.0,
                'notifikasi': [
                  {
                    'id': 1,
                    'judul': 'Jadwal Posyandu',
                    'pesan': 'Datang tepat waktu',
                    'tipe': 'jadwal',
                    'sudah_dibaca': 0,
                    'sent_at': '2026-08-29T00:00:00.000Z',
                    'rujukan_id': null,
                    'jadwal_id': 2,
                  },
                ],
              },
            }),
      );

      final result = await service.getNotifikasi();

      expect(result.total, 2);
      expect(result.belumDibaca, 1);
      expect(result.notifikasi, hasLength(1));
    });

    test('membaca jumlah belum_dibaca', () async {
      final service = NotifikasiService(
        dio: _dio((_) => {
              'data': {'belum_dibaca': 3},
            }),
      );

      expect(await service.getBelumDibaca(), 3);
    });

    test('menggunakan nilai aman untuk respons notifikasi kosong', () async {
      final service = NotifikasiService(
        dio: _dio((_) => {
              'data': <String, dynamic>{},
            }),
      );

      final result = await service.getNotifikasi();

      expect(result.total, 0);
      expect(result.belumDibaca, 0);
      expect(result.notifikasi, isEmpty);
    });
  });
}
