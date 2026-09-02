import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/core/constant/app_constants.dart';
import 'package:tumbuhapp/shared/models/anak_model.dart';
import 'package:tumbuhapp/shared/models/pemberian_model.dart';
import 'package:tumbuhapp/shared/models/pengukuran_model.dart';
import 'package:tumbuhapp/shared/models/rujukan_model.dart';
import 'package:tumbuhapp/shared/widgets/status_badge_widget.dart';

void main() {
  test('status pemantauan sedang memakai bahasa yang tidak menghakimi', () {
    expect(formatStatusPemantauan('perlu_perhatian'), 'Pantau Pertumbuhan');
  });

  testWidgets('status pantau pertumbuhan memakai warna biru', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(
            label: 'perlu_perhatian',
            type: StatusType.statusPemantauan,
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(StatusBadge),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    final label = tester.widget<Text>(find.text('Pantau Pertumbuhan'));

    expect(decoration.color, AppColors.risikoSedangBg);
    expect(label.style?.color, AppColors.risikoSedangText);
  });

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

  test('PengukuranModel membaca kontrak orang tua tanpa data teknis', () {
    final pengukuran = PengukuranModel.fromJson({
      'id': 10,
      'tanggal_ukur': '2026-08-29',
      'berat_badan': 12.5,
      'tinggi_badan': 88.4,
      'usia_bulan': 31,
      'status_bbu': 'berat_badan_normal',
      'status_tbu': 'pendek',
      'status_bbtb': 'gizi_baik',
      'status_imtu': 'gizi_baik',
      'status_pemantauan': 'perlu_perhatian',
      'created_at': '2026-08-29T00:00:00.000Z',
    });

    expect(pengukuran.statusBbu, 'berat_badan_normal');
    expect(pengukuran.statusTbu, 'pendek');
    expect(pengukuran.statusBbtb, 'gizi_baik');
    expect(pengukuran.statusImtu, 'gizi_baik');
    expect(pengukuran.statusPemantauan, 'perlu_perhatian');
    expect(pengukuran.usiaBulan, 31);
    expect(pengukuran.statusForIndicator('tbu'), 'pendek');
  });

  test('RujukanModel membaca kontrak orang tua tanpa skor prioritas', () {
    final rujukan = RujukanModel.fromJson({
      'id': 2,
      'status': 'diajukan',
      'catatan_kader': 'Perlu pemeriksaan',
      'created_at': '2026-08-29T00:00:00.000Z',
      'catatan_puskesmas': null,
      'validated_at': null,
      'tanggal_ukur': '2026-08-29',
      'berat_badan': 12.5,
      'tinggi_badan': 88.4,
      'ditangani_oleh': null,
    });

    expect(rujukan.status, 'diajukan');
    expect(rujukan.catatanPuskesmas, isNull);
    expect(rujukan.tanggalUkur, '2026-08-29');
  });

  test('model orang tua menolak field wajib yang hilang atau bertipe salah',
      () {
    final pengukuran = {
      'id': 10,
      'tanggal_ukur': '2026-08-29',
      'berat_badan': 12.5,
      'tinggi_badan': 88.4,
      'usia_bulan': 31,
      'status_bbu': 'berat_badan_normal',
      'status_tbu': 'pendek',
      'status_bbtb': 'gizi_baik',
      'status_imtu': 'gizi_baik',
      'status_pemantauan': 'perlu_perhatian',
      'created_at': '2026-08-29T00:00:00.000Z',
    };

    expect(
      () => PengukuranModel.fromJson({
        ...pengukuran,
        'berat_badan': '12.5',
      }),
      throwsFormatException,
    );
    expect(
      () => PengukuranModel.fromJson({
        ...pengukuran,
      }..remove('status_pemantauan')),
      throwsFormatException,
    );
    expect(
      () => RujukanModel.fromJson({
        'id': 2,
        'status': 'diproses',
        'created_at': '2026-02-30T00:00:00.000Z',
        'tanggal_ukur': '2026-08-29',
        'berat_badan': 12.5,
        'tinggi_badan': 88.4,
      }),
      throwsFormatException,
    );
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

  test('PemberianModel mengelompokkan jenis rinci untuk filter riwayat', () {
    PemberianModel pemberian(String jenis) => PemberianModel.fromJson({
          'id': 1,
          'jenis': jenis,
          'tanggal_pemberian': '2026-08-29',
          'created_at': '2026-08-29T00:00:00.000Z',
          'dicatat_oleh': 'Kader Satu',
        });

    for (final jenis in ['vitamin_a_merah', 'vitamin_a_biru']) {
      expect(pemberian(jenis).kategori, 'vitamin_a');
      expect(pemberian(jenis).sesuaiFilter('vitamin_a'), isTrue);
      expect(pemberian(jenis).sesuaiFilter('pmt'), isFalse);
    }

    for (final jenis in ['pmt_biskuit', 'pmt_susu', 'pmt_lainnya']) {
      expect(pemberian(jenis).kategori, 'pmt');
      expect(pemberian(jenis).sesuaiFilter('pmt'), isTrue);
      expect(pemberian(jenis).sesuaiFilter('vitamin_a'), isFalse);
    }

    expect(pemberian('obat_cacing').kategori, 'obat_cacing');
    expect(pemberian('obat_cacing').sesuaiFilter('obat_cacing'), isTrue);
    expect(pemberian('obat_cacing').sesuaiFilter('semua'), isTrue);
  });

  test('kode status antropometri diformat untuk tampilan', () {
    expect(formatStatusAntropometri('berat_badan_normal'), 'BB Normal');
    expect(formatStatusAntropometri('gizi_baik'), 'Gizi Baik');
    expect(formatStatusAntropometri('sangat_pendek'), 'Sangat Pendek');
  });
}
