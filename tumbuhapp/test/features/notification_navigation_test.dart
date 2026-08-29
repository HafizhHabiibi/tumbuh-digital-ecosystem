import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/core/navigation/notification_navigation.dart';
import 'package:tumbuhapp/shared/models/notifikasi_model.dart';

void main() {
  test('payload FCM dipetakan ke route GoRouter yang sesuai', () {
    expect(
      NotificationNavigation.pathFromData({
        'tipe': 'pengukuran',
        'anak_id': 'anak-1',
        'pengukuran_id': '12',
      }),
      '/anak/anak-1/pengukuran',
    );
    expect(
      NotificationNavigation.pathFromData({
        'tipe': 'rujukan',
        'anak_id': 'anak-1',
        'rujukan_id': '8',
      }),
      '/anak/anak-1/rujukan',
    );
    expect(
      NotificationNavigation.pathFromData({
        'tipe': 'jadwal',
        'jadwal_id': '4',
      }),
      '/jadwal',
    );
  });

  test('payload tanpa relasi aman kembali ke halaman notifikasi', () {
    expect(
      NotificationNavigation.pathFromData({'tipe': 'rujukan'}),
      '/notifikasi',
    );
    expect(
      NotificationNavigation.pathFromData({'tipe': 'unknown'}),
      '/notifikasi',
    );
  });

  test('NotifikasiModel membaca referensi pengukuran dan anak', () {
    final notification = NotifikasiModel.fromJson({
      'id': 1,
      'judul': 'Pengukuran Baru',
      'pesan': 'Hasil pengukuran tersedia',
      'tipe': 'pengukuran',
      'sudah_dibaca': 0,
      'sent_at': '2026-08-29T00:00:00.000Z',
      'pengukuran_id': '12',
      'anak_id': 'anak-1',
    });

    expect(notification.pengukuranId, 12);
    expect(notification.anakId, 'anak-1');
  });
}
