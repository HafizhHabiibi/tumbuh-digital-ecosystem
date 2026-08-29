import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/shared/models/anak_model.dart';
import 'package:tumbuhapp/shared/models/pemberian_model.dart';
import 'package:tumbuhapp/shared/models/pengukuran_model.dart';
import 'package:tumbuhapp/shared/models/rujukan_model.dart';
import 'package:tumbuhapp/shared/widgets/status_badge_widget.dart';

void main() {
  test('AnakModel membaca NIK dari kontrak backend', () {
    final anak = AnakModel.fromJson({
      'id': 'anak-id',
      'nama': 'Budi',
      'jenis_kelamin': 'L',
      'tanggal_lahir': '2024-01-01',
      'nik': '1234567890123456',
      'created_at': '2026-08-29T00:00:00.000Z',
    });

    expect(anak.nik, '1234567890123456');
  });

  test('PengukuranModel membaca status antropometri dan SAW backend', () {
    final pengukuran = PengukuranModel.fromJson({
      'id': 10,
      'tanggal_ukur': '2026-08-29',
      'berat_badan': '12.5',
      'tinggi_badan': '88.4',
      'zscore_bbu': '-1.2',
      'zscore_tbu': '-2.1',
      'zscore_bbtb': '0.4',
      'zscore_imtu': '0.3',
      'status_bbu': 'berat_badan_normal',
      'status_tbu': 'pendek',
      'status_bbtb': 'gizi_baik',
      'status_imtu': 'gizi_baik',
      'skor_saw': '0.35',
      'kategori_prioritas': 'sedang',
      'created_at': '2026-08-29T00:00:00.000Z',
    });

    expect(pengukuran.zscoreImtu, 0.3);
    expect(pengukuran.statusBbu, 'berat_badan_normal');
    expect(pengukuran.statusTbu, 'pendek');
    expect(pengukuran.statusBbtb, 'gizi_baik');
    expect(pengukuran.statusImtu, 'gizi_baik');
    expect(pengukuran.skorSaw, 0.35);
    expect(pengukuran.kategoriPrioritas, 'sedang');
    expect(pengukuran.statusForIndicator('tbu'), 'pendek');
  });

  test('RujukanModel membaca skor dan kategori prioritas backend', () {
    final rujukan = RujukanModel.fromJson({
      'id': 2,
      'status': 'diajukan',
      'catatan_kader': 'Perlu pemeriksaan',
      'created_at': '2026-08-29T00:00:00.000Z',
      'skor_saw': '0.72',
      'kategori_prioritas': 'tinggi',
    });

    expect(rujukan.skorSaw, 0.72);
    expect(rujukan.kategoriPrioritas, 'tinggi');
  });

  test('PemberianModel membentuk nama item dari jenis backend', () {
    PemberianModel pemberian(String jenis) => PemberianModel.fromJson({
          'id': 1,
          'jenis': jenis,
          'tanggal_pemberian': '2026-08-29',
          'created_at': '2026-08-29T00:00:00.000Z',
          'dicatat_oleh': 'Kader Satu',
        });

    expect(pemberian('vitamin_a_merah').namaItem, 'Vitamin A Merah');
    expect(pemberian('vitamin_a_biru').namaItem, 'Vitamin A Biru');
    expect(pemberian('obat_cacing').namaItem, 'Obat Cacing');
    expect(pemberian('pmt_biskuit').namaItem, 'PMT Biskuit');
    expect(pemberian('pmt_susu').namaItem, 'PMT Susu');
    expect(pemberian('pmt_lainnya').namaItem, 'PMT Lainnya');
  });

  test('kode status antropometri diformat untuk tampilan', () {
    expect(formatStatusAntropometri('berat_badan_normal'), 'BB Normal');
    expect(formatStatusAntropometri('gizi_baik'), 'Gizi Baik');
    expect(formatStatusAntropometri('sangat_pendek'), 'Sangat Pendek');
  });
}
