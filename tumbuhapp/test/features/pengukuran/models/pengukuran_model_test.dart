import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/shared/models/pengukuran_model.dart';

Map<String, dynamic> _kontrakOrangTua({
  String statusPemantauan = 'perlu_perhatian',
}) =>
    {
      'id': 501,
      'tanggal_ukur': '2026-08-26',
      'berat_badan': 11,
      'tinggi_badan': 85.5,
      'lingkar_kepala': 48,
      'lingkar_lengan': null,
      'usia_bulan': 24,
      'status_bbu': 'berat_badan_normal',
      'status_tbu': 'normal',
      'status_bbtb': 'gizi_baik',
      'status_imtu': 'gizi_baik',
      'status_pemantauan': statusPemantauan,
      'created_at': '2026-08-26T03:00:00.000Z',
    };

void main() {
  test('mem-parsing kontrak pengukuran orang tua tanpa field teknis', () {
    final json = _kontrakOrangTua();
    final model = PengukuranModel.fromJson(json);

    expect(json.containsKey('zscore_bbu'), isFalse);
    expect(json.containsKey('skor_saw'), isFalse);
    expect(model.id, 501);
    expect(model.beratBadan, 11);
    expect(model.tinggiBadan, 85.5);
    expect(model.usiaBulan, 24);
    expect(model.statusForIndicator('bbu'), 'berat_badan_normal');
    expect(model.statusForIndicator('imtu'), 'gizi_baik');
  });

  test('mem-parsing seluruh nilai status pemantauan yang didukung', () {
    for (final status in ['rutin', 'perlu_perhatian', 'konsultasi']) {
      final model = PengukuranModel.fromJson(
        _kontrakOrangTua(statusPemantauan: status),
      );

      expect(model.statusPemantauan, status);
    }
  });

  test('field teknis tambahan tidak menjadi dependensi model orang tua', () {
    final model = PengukuranModel.fromJson({
      ..._kontrakOrangTua(),
      'zscore_bbu': -0.73,
      'zscore_tbu': -0.64,
      'zscore_bbtb': -0.28,
      'zscore_imtu': -0.34,
      'skor_saw': 0.0825,
      'kategori_prioritas': 'rendah',
      'detail_saw': const [
        {'nama_kriteria': 'zscore_bbu', 'bobot': 0.25},
      ],
    });

    expect(model.statusPemantauan, 'perlu_perhatian');
    expect(model.statusBbtb, 'gizi_baik');
  });

  test('respons tanpa seluruh field teknis tetap valid', () {
    expect(
      () => PengukuranModel.fromJson(_kontrakOrangTua()),
      returnsNormally,
    );
  });
}
