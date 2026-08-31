import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/features/dashboard/providers/anak_provider.dart';
import 'package:tumbuhapp/features/dashboard/screens/detail_anak_screen.dart';
import 'package:tumbuhapp/features/pengukuran/data/pengukuran_service.dart';
import 'package:tumbuhapp/features/pengukuran/providers/pengukuran_provider.dart';
import 'package:tumbuhapp/features/pengukuran/screens/detail_pengukuran_screen.dart';
import 'package:tumbuhapp/features/pengukuran/screens/grafik_pertumbuhan_screen.dart';
import 'package:tumbuhapp/features/pengukuran/screens/riwayat_pengukuran_screen.dart';
import 'package:tumbuhapp/features/rujukan/data/rujukan_service.dart';
import 'package:tumbuhapp/features/rujukan/providers/rujukan_provider.dart';
import 'package:tumbuhapp/features/rujukan/screens/status_rujukan_screen.dart';
import 'package:tumbuhapp/shared/models/anak_model.dart';
import 'package:tumbuhapp/shared/models/insight_model.dart';
import 'package:tumbuhapp/shared/models/pengukuran_model.dart';
import 'package:tumbuhapp/shared/models/pengukuran_response.dart';
import 'package:tumbuhapp/shared/models/rujukan_model.dart';

const _anakId = '01900000-0000-7000-8000-000000000001';

final _anak = AnakModel(
  id: _anakId,
  nama: 'Budi',
  jenisKelamin: 'L',
  tanggalLahir: '2024-08-26',
  nik: '3200000000000001',
  createdAt: '2026-08-26T03:00:00.000Z',
  namaOrangTua: 'Aminah',
  noHpOrangTua: '081234567890',
  alamatOrangTua: 'Desa Melati',
);

final _pengukuran = PengukuranModel(
  id: 501,
  tanggalUkur: '2026-08-26',
  beratBadan: 11,
  tinggiBadan: 85.5,
  lingkarKepala: 48,
  lingkarLengan: 15,
  usiaBulan: 24,
  statusBbu: 'berat_badan_normal',
  statusTbu: 'normal',
  statusBbtb: 'gizi_baik',
  statusImtu: 'gizi_baik',
  statusPemantauan: 'perlu_perhatian',
  createdAt: '2026-08-26T03:00:00.000Z',
);

final _response = PengukuranResponse(
  anak: _anak,
  riwayat: [_pengukuran],
);

final _rujukan = RujukanModel(
  id: 81,
  status: 'ditangani',
  catatanKader: 'Perlu pemantauan lanjutan',
  catatanPuskesmas: 'Jadwalkan pemeriksaan ulang',
  createdAt: '2026-08-26T04:00:00.000Z',
  validatedAt: '2026-08-27T02:00:00.000Z',
  tanggalUkur: '2026-08-26',
  beratBadan: 11,
  tinggiBadan: 85.5,
  ditanganiOleh: 'dr. Sari',
);

class _StaticInsightGateway implements InsightGateway {
  const _StaticInsightGateway();

  @override
  Future<InsightModel> getInsight(int pengukuranId) async {
    return const InsightModel(
      status: InsightStatus.completed,
      insightTeks: 'Pertumbuhan anak perlu dipantau secara rutin.',
      insightGeneratedAt: '2026-08-26T04:00:00.000Z',
    );
  }
}

class _StaticRujukanNotifier extends RujukanNotifier {
  _StaticRujukanNotifier() : super(RujukanService(dio: Dio())) {
    state = RujukanState(anak: _anak, rujukan: [_rujukan]);
  }

  @override
  Future<void> fetchRujukan(String anakId) async {}
}

void _expectDataTeknisTidakTampil() {
  for (final text in ['Z-Score', 'Skor SAW', 'Skor Akhir', '0.0000']) {
    expect(find.textContaining(text, findRichText: true), findsNothing);
  }
}

Widget _app(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets(
    'detail pengukuran menampilkan status tanpa data teknis',
    (tester) async {
      await tester.pumpWidget(
        _app(
          const DetailPengukuranScreen(pengukuranId: 501),
          overrides: [
            selectedPengukuranProvider.overrideWith((ref) => _pengukuran),
            insightProvider.overrideWith(
              (ref, id) => InsightController(
                pengukuranId: id,
                gateway: const _StaticInsightGateway(),
              ),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Status Antropometri'), findsOneWidget);
      expect(find.text('Status Pemantauan'), findsOneWidget);
      expect(find.text('Gizi Baik'), findsWidgets);
      expect(find.text('Perlu Perhatian'), findsOneWidget);
      _expectDataTeknisTidakTampil();
    },
  );

  testWidgets(
    'riwayat pengukuran menampilkan kategori tanpa data teknis',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _app(
          const RiwayatPengukuranScreen(anakId: _anakId),
          overrides: [
            riwayatPengukuranProvider.overrideWith(
              (ref, id) async => _response,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gizi Baik'), findsOneWidget);
      expect(find.text('Perlu Perhatian'), findsOneWidget);
      expect(find.text('Berat Badan'), findsOneWidget);
      expect(find.text('Tinggi Badan'), findsOneWidget);
      expect(find.text('Usia saat diukur: 2 tahun'), findsOneWidget);
      expect(find.text('Status Gizi'), findsOneWidget);
      expect(find.text('Saran Pemantauan'), findsOneWidget);
      expect(find.text('Terbaru'), findsOneWidget);
      expect(find.text('Lihat detail pengukuran'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('riwayat-pengukuran-501')),
        findsOneWidget,
      );
      _expectDataTeknisTidakTampil();
    },
  );

  testWidgets(
    'grafik pertumbuhan memakai nilai fisik dan kategori tanpa data teknis',
    (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _app(
          const GrafikPertumbuhanScreen(anakId: _anakId),
          overrides: [
            riwayatPengukuranProvider.overrideWith(
              (ref, id) async => _response,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Perkembangan Berat Badan'), findsOneWidget);
      expect(find.text('Perkembangan Tinggi Badan'), findsOneWidget);
      expect(find.text('Status Gizi per Pengukuran'), findsOneWidget);
      expect(find.text('Gizi Baik'), findsWidgets);
      _expectDataTeknisTidakTampil();
    },
  );

  testWidgets(
    'status rujukan menampilkan tindak lanjut tanpa data teknis',
    (tester) async {
      await tester.pumpWidget(
        _app(
          const StatusRujukanScreen(anakId: _anakId),
          overrides: [
            rujukanProvider.overrideWith((ref) => _StaticRujukanNotifier()),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Ditangani'), findsWidgets);
      expect(find.text('Alasan / Catatan Kader'), findsOneWidget);
      expect(find.text('Tindak Lanjut Puskesmas'), findsOneWidget);
      _expectDataTeknisTidakTampil();
    },
  );

  testWidgets(
    'detail anak hanya menampilkan menu pertumbuhan yang relevan',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _app(
          const DetailAnakScreen(anakId: _anakId),
          overrides: [
            detailAnakProvider.overrideWith((ref, id) async => _anak),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Riwayat Pengukuran'), findsOneWidget);
      expect(
          find.text('Lihat pertumbuhan dan status gizi anak'), findsOneWidget);
      expect(find.text('Grafik Pertumbuhan'), findsOneWidget);
      _expectDataTeknisTidakTampil();
    },
  );
}
