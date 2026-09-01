import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tumbuhapp/features/rujukan/data/rujukan_service.dart';
import 'package:tumbuhapp/features/rujukan/providers/rujukan_provider.dart';
import 'package:tumbuhapp/features/rujukan/screens/status_rujukan_screen.dart';
import 'package:tumbuhapp/shared/models/anak_model.dart';
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

class _StaticRujukanNotifier extends RujukanNotifier {
  _StaticRujukanNotifier(List<RujukanModel> items)
      : super(RujukanService(dio: Dio()), _anakId) {
    state = RujukanState(anak: _anak, rujukan: items);
  }

  var refreshCount = 0;

  @override
  Future<void> fetchRujukan() async {
    refreshCount++;
  }
}

Widget _app(_StaticRujukanNotifier notifier) => ProviderScope(
      overrides: [
        rujukanProvider(_anakId).overrideWith((ref) => notifier),
      ],
      child: const MaterialApp(
        home: StatusRujukanScreen(anakId: _anakId),
      ),
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id');
  });

  testWidgets('menampilkan konteks pengukuran dan waktu lifecycle rujukan',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final notifier = _StaticRujukanNotifier([
      RujukanModel(
        id: 81,
        status: 'selesai',
        catatanKader: 'Perlu pemantauan lanjutan',
        catatanPuskesmas: 'Kontrol kembali bulan depan',
        createdAt: '2026-08-26T04:00:00.000Z',
        validatedAt: '2026-08-27T02:00:00.000Z',
        completedAt: '2026-08-28T03:00:00.000Z',
        tanggalUkur: '2026-08-26',
        beratBadan: 11,
        tinggiBadan: 85.5,
        ditanganiOleh: 'dr. Sari',
      ),
    ]);

    await tester.pumpWidget(_app(notifier));
    await tester.pumpAndSettle();

    expect(find.text('Dasar Rujukan'), findsOneWidget);
    expect(find.text('Pengukuran 26 Agustus 2026'), findsOneWidget);
    expect(find.text('Mulai Ditangani'), findsOneWidget);
    expect(find.text('Selesai Ditangani'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state tetap dapat ditarik untuk memuat ulang',
      (tester) async {
    final notifier = _StaticRujukanNotifier([]);
    await tester.pumpWidget(_app(notifier));
    await tester.pumpAndSettle();

    expect(find.text('Tidak Ada Rujukan'), findsOneWidget);
    expect(find.byKey(const ValueKey('empty-rujukan-scroll')), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('empty-rujukan-scroll')),
      const Offset(0, 300),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(notifier.refreshCount, 1);
  });
}
