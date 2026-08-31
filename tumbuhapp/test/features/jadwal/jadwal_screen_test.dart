import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tumbuhapp/features/jadwal/data/jadwal_service.dart';
import 'package:tumbuhapp/features/jadwal/providers/jadwal_provider.dart';
import 'package:tumbuhapp/features/jadwal/screens/jadwal_screen.dart';
import 'package:tumbuhapp/shared/models/jadwal_model.dart';

String _tanggalRelatif(int selisihHari) {
  final tanggal = DateTime.now().add(Duration(days: selisihHari));
  String duaDigit(int nilai) => nilai.toString().padLeft(2, '0');
  return '${tanggal.year}-${duaDigit(tanggal.month)}-${duaDigit(tanggal.day)}';
}

JadwalModel _jadwal(int id, int selisihHari) {
  return JadwalModel(
    id: id,
    tanggal: _tanggalRelatif(selisihHari),
    waktuMulai: '08:00:00',
    waktuSelesai: '10:00:00',
    lokasi: 'Posyandu Melati $id',
    keterangan: 'Pemantauan rutin',
    createdAt: '2026-08-01T00:00:00.000Z',
    dibuatOleh: 'Kader Satu',
  );
}

class _StaticJadwalNotifier extends JadwalNotifier {
  _StaticJadwalNotifier(List<JadwalModel> jadwal)
      : super(JadwalService(dio: Dio())) {
    state = JadwalState(jadwal: jadwal);
  }

  @override
  Future<void> fetchJadwal() async {}
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id');
  });

  test('state memisahkan jadwal mendatang dan terlewat dengan urutan tepat',
      () {
    final jadwalLama = _jadwal(1, -10);
    final jadwalTerlewatTerbaru = _jadwal(2, -2);
    final jadwalHariIni = _jadwal(3, 0);
    final jadwalMendatang = _jadwal(4, 7);
    final state = JadwalState(
      jadwal: [
        jadwalMendatang,
        jadwalLama,
        jadwalHariIni,
        jadwalTerlewatTerbaru,
      ],
    );

    expect(state.jadwalMendatang.map((jadwal) => jadwal.id), [3, 4]);
    expect(state.jadwalTerlewat.map((jadwal) => jadwal.id), [2, 1]);
  });

  testWidgets('tetap menampilkan riwayat ketika seluruh jadwal sudah lewat',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jadwalProvider.overrideWith(
            (ref) => _StaticJadwalNotifier([_jadwal(1, -2)]),
          ),
        ],
        child: const MaterialApp(home: JadwalScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada jadwal Posyandu mendatang.'), findsOneWidget);
    expect(find.text('Riwayat Jadwal'), findsOneWidget);
    expect(find.text('Terlewat'), findsOneWidget);
    expect(find.text('Posyandu Melati 1'), findsOneWidget);
  });

  testWidgets('menampilkan bagian jadwal mendatang dan riwayat bersamaan',
      (tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jadwalProvider.overrideWith(
            (ref) => _StaticJadwalNotifier([
              _jadwal(1, -2),
              _jadwal(2, 5),
            ]),
          ),
        ],
        child: const MaterialApp(home: JadwalScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jadwal Mendatang'), findsOneWidget);
    expect(find.text('Riwayat Jadwal'), findsOneWidget);
    expect(find.text('Posyandu Melati 1'), findsOneWidget);
    expect(find.text('Posyandu Melati 2'), findsOneWidget);
  });
}
